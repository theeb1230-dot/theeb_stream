import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'stream_security.dart';

/// Web stream resolution service.
/// Calls the worker API to extract actual HLS URLs server-side.
class WebStreamService {
  static const String _tag = 'WebStreamService';
  static const String _workerUrl =
      'https://maxstream-extractor.maxstream123.workers.dev';

  // A dead provider must not hold the whole playback flow hostage. Four
  // sequential 20-second waits used to make a complete fallback take up to
  // ~80 seconds. Keep each provider bounded and the complete attempt bounded.
  static const Duration _serverTimeout = Duration(seconds: 8);
  static const Duration _overallResolveTimeout = Duration(seconds: 24);

  static const List<Map<String, String>> servers = [
    {
      'name': 'VixSrc',
      'id': 'vixsrc',
      'movieUrl': 'https://vixsrc.to/api/movie/{id}?lang=en',
      'tvUrl': 'https://vixsrc.to/api/tv/{id}/{season}/{episode}?lang=en',
    },
    {
      'name': 'VidLink',
      'id': 'vidlink',
      'movieUrl': 'https://vidlink.pro/movie/{id}',
      'tvUrl': 'https://vidlink.pro/tv/{id}/{season}/{episode}',
    },
    {
      'name': '2Embed',
      'id': '2embed',
      'movieUrl': 'https://www.2embed.cc/embed/{id}',
      'tvUrl': 'https://www.2embed.cc/embedtv/{id}&s={season}&e={episode}',
    },
    {
      'name': 'Goodstream',
      'id': 'goodstream',
      'movieUrl': 'https://goodstream.one/movie/{id}',
      'tvUrl': 'https://goodstream.one/tv/{id}/{season}/{episode}',
    },
  ];

  static Future<Map<String, dynamic>?> resolveFromServer({
    required String serverId,
    required String tmdbId,
    required bool isMovie,
    int season = 1,
    int episode = 1,
    bool directOnly = false,
  }) async {
    debugPrint('$_tag: Resolving from $serverId for TMDB $tmdbId');

    try {
      final url =
          '$_workerUrl/api/extract'
          '?tmdb_id=$tmdbId'
          '&is_movie=$isMovie'
          '&season=$season'
          '&episode=$episode'
          '&server=$serverId';

      final response = await http
          .get(Uri.parse(url), headers: const {'Accept': 'application/json'})
          .timeout(_serverTimeout);
      if (response.statusCode != 200) {
        debugPrint('$_tag: $serverId returned HTTP ${response.statusCode}');
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('$_tag: $serverId returned an invalid payload');
        return null;
      }
      final data = decoded;
      final streamUrl = data['url']?.toString() ?? '';
      final streamUri = Uri.tryParse(streamUrl);
      final workerUri = Uri.parse(_workerUrl);
      final isWorkerMediaUrl =
          streamUri != null &&
          streamUri.scheme == 'https' &&
          streamUri.host == workerUri.host &&
          streamUri.path == '/api/media' &&
          streamUri.queryParameters.containsKey('token') &&
          streamUri.queryParameters.containsKey('sig');
      if (isWorkerMediaUrl && data['type'] == 'hls') {
        return StreamSecurity.sanitizeResolverResult({
          'url': streamUrl,
          'source': data['source'] as String? ?? serverId,
          'type': 'hls',
          'headers': <String, String>{},
        });
      }
      if (data['type'] == 'embed') {
        if (directOnly) {
          debugPrint('$_tag: Skipping embed-only result for native playback');
          return null;
        }
        final embed = _sanitizeEmbedUrl(streamUrl);
        if (embed != null) {
          return StreamSecurity.sanitizeResolverResult({
            'url': embed,
            'source': data['source'] as String? ?? serverId,
            'type': 'embed',
            'headers': <String, String>{},
          });
        }
        debugPrint('$_tag: Worker returned an unsafe embed URL');
      } else {
        debugPrint('$_tag: Worker returned an unsafe or unsupported stream URL');
      }
    } on TimeoutException {
      debugPrint('$_tag: $serverId timed out after ${_serverTimeout.inSeconds}s');
    } on FormatException {
      debugPrint('$_tag: $serverId returned malformed JSON');
    } catch (e) {
      debugPrint('$_tag: Worker call failed for $serverId: $e');
    }

    return null;
  }

  static Future<Map<String, dynamic>?> resolveStream({
    required String tmdbId,
    required bool isMovie,
    int season = 1,
    int episode = 1,
    String title = '',
    bool directOnly = false,
  }) async {
    Future<Map<String, dynamic>?> tryServers() async {
      for (final server in servers) {
        final result = await resolveFromServer(
          serverId: server['id']!,
          tmdbId: tmdbId,
          isMovie: isMovie,
          season: season,
          episode: episode,
          directOnly: directOnly,
        );
        if (result != null) {
          debugPrint('$_tag: Success with ${server['name']}');
          return result;
        }
      }
      return null;
    }

    try {
      final result = await tryServers().timeout(_overallResolveTimeout);
      if (result == null) {
        debugPrint('$_tag: No streaming source was found');
      }
      return result;
    } on TimeoutException {
      debugPrint(
        '$_tag: Resolver exhausted ${_overallResolveTimeout.inSeconds}s budget',
      );
      return null;
    }
  }

  static List<Map<String, String>> getServerList() {
    return servers.map((s) => {'name': s['name']!, 'id': s['id']!}).toList();
  }

  static const List<String> _embedAllowedHosts = [
    'vidlink.pro',
    'goodstream.one',
    'www.2embed.cc',
    '2embed.cc',
  ];

  static String? _sanitizeEmbedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return null;
    final host = uri.host.toLowerCase();
    if (!_embedAllowedHosts.any(
      (allowed) => host == allowed || host.endsWith('.$allowed'),
    )) {
      return null;
    }
    return uri.toString();
  }
}
