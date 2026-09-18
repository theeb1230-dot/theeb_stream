import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'native_stream_extractor.dart';
import 'stream_security.dart';
import 'web_stream_service.dart';

/// Stream extraction service.
/// On mobile: delegates to native Android Kotlin extractors via platform channel.
/// On web: uses web-compatible embed URLs and HTTP requests.
class DirectM3u8Service {
  static const String _tag = 'DirectM3u8Service';

  static bool get _useAndroidNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _useWorkerResolver =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.iOS;

  static Future<Map<String, dynamic>?> fetchMovieStreamUrl(
    String title,
    int? year,
    String? tmdbId,
  ) async {
    final id = tmdbId?.trim();
    if (id == null || id.isEmpty) return null;
    debugPrint('$_tag: Resolving movie $title (TMDB: $id)');

    if (_useWorkerResolver) {
      final result = await WebStreamService.resolveStream(
        tmdbId: id,
        isMovie: true,
        title: title,
        directOnly: !kIsWeb,
      );
      return StreamSecurity.sanitizeResolverResult(result);
    }
    if (!_useAndroidNative) return null;

    final result = await NativeStreamExtractor.resolveStream(
      tmdbId: id,
      isMovie: true,
      title: title,
    );

    final sanitized = StreamSecurity.sanitizeResolverResult(result);
    if (sanitized != null) return sanitized;

    final alternatives = await NativeStreamExtractor.resolveStreams(
      tmdbId: id,
      isMovie: true,
      title: title,
    );
    for (final candidate in alternatives) {
      final fallback = StreamSecurity.sanitizeResolverResult(candidate);
      if (fallback != null &&
          (fallback['url']?.toString().isNotEmpty ?? false)) {
        return fallback;
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchSeriesStreamUrl(
    String title,
    int season,
    int episode,
    String? tmdbId,
  ) async {
    final id = tmdbId?.trim();
    if (id == null || id.isEmpty) return null;
    debugPrint('$_tag: Resolving $title S${season}E$episode (TMDB: $id)');

    if (_useWorkerResolver) {
      final result = await WebStreamService.resolveStream(
        tmdbId: id,
        isMovie: false,
        season: season,
        episode: episode,
        title: title,
        directOnly: !kIsWeb,
      );
      return StreamSecurity.sanitizeResolverResult(result);
    }
    if (!_useAndroidNative) return null;

    final result = await NativeStreamExtractor.resolveStream(
      tmdbId: id,
      isMovie: false,
      season: season,
      episode: episode,
      title: title,
    );

    final sanitized = StreamSecurity.sanitizeResolverResult(result);
    if (sanitized != null) return sanitized;

    final alternatives = await NativeStreamExtractor.resolveStreams(
      tmdbId: id,
      isMovie: false,
      season: season,
      episode: episode,
      title: title,
    );
    for (final candidate in alternatives) {
      final fallback = StreamSecurity.sanitizeResolverResult(candidate);
      if (fallback != null &&
          (fallback['url']?.toString().isNotEmpty ?? false)) {
        return fallback;
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> fetchAvailableStreams({
    required String title,
    required String tmdbId,
    required bool isMovie,
    int season = 1,
    int episode = 1,
  }) async {
    if (kIsWeb) {
      // Embed templates are inventory, not proof of a playable stream. Keep
      // them selectable for the web fallback but never label them as a
      // player-start-confirmed source merely because a URL can be constructed.
      final sources = WebStreamService.servers;
      return sources.map((source) {
        final url = isMovie
            ? source['movieUrl']!.replaceAll('{id}', tmdbId)
            : source['tvUrl']!
                  .replaceAll('{id}', tmdbId)
                  .replaceAll('{season}', season.toString())
                  .replaceAll('{episode}', episode.toString());
        return {
          'url': url,
          'source': source['name'],
          'type': 'embed',
          'isEmbed': true,
          'available': false,
          'playbackStatus': 'uncertain_webview',
        };
      }).toList();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final attempts = await Future.wait(
        WebStreamService.servers.map((source) async {
          final result = await WebStreamService.resolveFromServer(
            serverId: source['id']!,
            tmdbId: tmdbId,
            isMovie: isMovie,
            season: season,
            episode: episode,
            directOnly: true,
          );
          final sanitized = StreamSecurity.sanitizeResolverResult(result);
          return sanitized ??
              <String, dynamic>{
                'url': '',
                'source': source['name'],
                'type': 'unavailable',
                'available': false,
                'playbackStatus': 'unconfirmed',
              };
        }),
      );
      return attempts;
    }

    if (!_useAndroidNative) return const [];

    final streams = await NativeStreamExtractor.resolveStreams(
      tmdbId: tmdbId,
      isMovie: isMovie,
      season: season,
      episode: episode,
      title: title,
    );
    return streams.map((stream) {
      final url = stream['url']?.toString() ?? '';
      if (url.isEmpty) {
        return {
          ...stream,
          'headers': StreamSecurity.sanitizeHeaders(
            stream['headers'] is Map ? stream['headers'] as Map : null,
          ),
        };
      }
      return StreamSecurity.sanitizeResolverResult(stream);
    }).whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>?> resolveServer({
    required String serverName,
    required String title,
    required String tmdbId,
    required bool isMovie,
    int season = 1,
    int episode = 1,
  }) async {
    if (kIsWeb) return null;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final server = WebStreamService.servers.where(
        (entry) => entry['name']?.toLowerCase() == serverName.toLowerCase(),
      );
      if (server.isEmpty) return null;
      final result = await WebStreamService.resolveFromServer(
        serverId: server.first['id']!,
        tmdbId: tmdbId,
        isMovie: isMovie,
        season: season,
        episode: episode,
        directOnly: true,
      );
      return StreamSecurity.sanitizeResolverResult(result);
    }
    if (!_useAndroidNative) return null;
    final result = await NativeStreamExtractor.resolveServer(
      serverName: serverName,
      tmdbId: tmdbId,
      isMovie: isMovie,
      season: season,
      episode: episode,
      title: title,
    );
    return StreamSecurity.sanitizeResolverResult(result);
  }

  /// Lightweight transport pre-flight only. A true result means the resource
  /// is readable, not that playback has started. Player-start confirmation is
  /// deliberately owned by PlaybackStartGuard in the player runtime.
  static Future<bool> validateStream(
    String url, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Browser/embed reachability cannot prove media playback. Fail closed so
    // diagnostics cannot turn a constructed embed URL green.
    if (kIsWeb) return false;
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return false;

    final client = http.Client();
    try {
      final request = http.Request('GET', uri)
        ..headers.addAll(headers)
        ..headers.putIfAbsent(
          'User-Agent',
          () => 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
        );
      final response = await client.send(request).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('$_tag: reject $url -> HTTP ${response.statusCode}');
        return false;
      }
      final bytes = <int>[];
      await for (final chunk in response.stream.timeout(timeout)) {
        bytes.addAll(chunk);
        if (bytes.length > 65536) break;
      }
      if (bytes.isEmpty) {
        debugPrint('$_tag: reject $url -> empty body');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('$_tag: reject $url -> $e');
      return false;
    } finally {
      client.close();
    }
  }

  static const List<Map<String, String>> _embedSources = [
    {
      'name': 'VidLink',
      'movieUrl': 'https://vidlink.pro/movie/{id}',
      'tvUrl': 'https://vidlink.pro/tv/{id}/{season}/{episode}',
    },
  ];

  static List<Map<String, String>> getEmbedSources() => List.from(_embedSources);

  static String generateMovieEmbedUrl(String tmdbId, String sourceName) {
    final s = _embedSources.firstWhere(
      (s) => s['name'] == sourceName,
      orElse: () => _embedSources.first,
    );
    return s['movieUrl']!.replaceAll('{id}', tmdbId);
  }

  static String generateTvEmbedUrl(
    String tmdbId,
    int season,
    int episode,
    String sourceName,
  ) {
    final s = _embedSources.firstWhere(
      (s) => s['name'] == sourceName,
      orElse: () => _embedSources.first,
    );
    return s['tvUrl']!
        .replaceAll('{id}', tmdbId)
        .replaceAll('{season}', season.toString())
        .replaceAll('{episode}', episode.toString());
  }
}
