import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../services/native_stream_extractor.dart';

class ProviderStatus {
  final String name;
  final String domain;
  final String type; // 'server', 'extractor-api', 'extractor-webview', 'extractor-native'
  final bool? healthy;
  final String? error;
  final int? responseMs;

  const ProviderStatus({
    required this.name,
    required this.domain,
    required this.type,
    this.healthy,
    this.error,
    this.responseMs,
  });

  ProviderStatus copyWith({bool? healthy, String? error, int? responseMs}) {
    return ProviderStatus(
      name: name,
      domain: domain,
      type: type,
      healthy: healthy,
      error: error,
      responseMs: responseMs,
    );
  }
}

class ProviderHealthScreen extends StatefulWidget {
  const ProviderHealthScreen({super.key});

  @override
  State<ProviderHealthScreen> createState() => _ProviderHealthScreenState();
}

class _ProviderHealthScreenState extends State<ProviderHealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Servers ──
  final List<ProviderStatus> _servers = const [
    ProviderStatus(name: 'VixSrc', domain: 'vixsrc.to', type: 'server'),
    ProviderStatus(name: 'VidLink', domain: 'vidlink.pro', type: 'server'),
    ProviderStatus(name: '2Embed', domain: '2embed.cc', type: 'server'),
    ProviderStatus(name: 'Videasy', domain: 'player.videasy.to', type: 'server'),
    ProviderStatus(name: 'VidFast', domain: 'vidfast.vc', type: 'server'),
    ProviderStatus(name: 'VidsrcRu', domain: 'vidsrc.ru', type: 'server'),
    ProviderStatus(name: 'Moflix', domain: 'moflix-stream.xyz', type: 'server'),
    ProviderStatus(name: 'Community', domain: 'streamingunity.dog', type: 'server'),
    ProviderStatus(name: 'Vidrock', domain: 'vidrock.net', type: 'server'),
    ProviderStatus(name: 'Vidzee', domain: 'vidzee.space', type: 'server'),
    ProviderStatus(name: 'PrimeSrc', domain: 'primesrc.me', type: 'server'),
    ProviderStatus(name: 'Frembed', domain: 'frembed.click', type: 'server'),
  ];

  // ── Extractors (active registry + inactive/defined ones) ──
  final List<ProviderStatus> _extractors = const [
    // Active – WebView-based
    ProviderStatus(name: 'VidLink', domain: 'vidlink.pro', type: 'extractor-webview'),
    ProviderStatus(name: 'Mov2Day', domain: 'mov2day.xyz', type: 'extractor-webview'),
    ProviderStatus(name: 'VidsrcRu', domain: 'vidsrc.ru', type: 'extractor-webview'),
    ProviderStatus(name: 'StreamWish', domain: 'streamwish.to', type: 'extractor-webview'),
    ProviderStatus(name: 'VidLove', domain: 'vidlove.cc', type: 'extractor-webview'),
    // Active – API / native
    ProviderStatus(name: 'VixSrc', domain: 'vixsrc.to', type: 'extractor-native'),
    ProviderStatus(name: 'Vidsrc', domain: 'vidsrc-embed.ru', type: 'extractor-native'),
    ProviderStatus(name: 'PrimeSrc', domain: 'primesrc.me', type: 'extractor-api'),
    ProviderStatus(name: 'Videasy', domain: 'videasy.to', type: 'extractor-native'),
    ProviderStatus(name: 'VidFast', domain: 'vidfast.vc', type: 'extractor-native'),
    ProviderStatus(name: 'Voe', domain: 'voe.sx', type: 'extractor-native'),
    ProviderStatus(name: 'Streamtape', domain: 'streamtape.com', type: 'extractor-native'),
    ProviderStatus(name: '2Embed', domain: '2embed.cc', type: 'extractor-native'),
    ProviderStatus(name: 'Videm', domain: 'videm.xyz', type: 'extractor-native'),
    ProviderStatus(name: 'Filemoon', domain: 'filemoon.sx', type: 'extractor-native'),
    ProviderStatus(name: 'Dood', domain: 'dood.pm', type: 'extractor-native'),
    ProviderStatus(name: 'VidMoLy', domain: 'vidmoly.to', type: 'extractor-native'),
    ProviderStatus(name: 'LuluVdo', domain: 'luluvdo.com', type: 'extractor-native'),
    ProviderStatus(name: 'MixDrop', domain: 'mixdrop.to', type: 'extractor-native'),
    ProviderStatus(name: 'Supervideo', domain: 'supervideo.cc', type: 'extractor-native'),
    ProviderStatus(name: 'Rabbitstream', domain: 'rabbitstream.net', type: 'extractor-native'),
    ProviderStatus(name: 'Megacloud', domain: 'megacloud.club', type: 'extractor-native'),
    ProviderStatus(name: 'GxPlayer', domain: 'gxplayer.net', type: 'extractor-native'),
    ProviderStatus(name: 'Veev', domain: 'veev.to', type: 'extractor-native'),
    ProviderStatus(name: 'Vidplay', domain: 'vidplay.online', type: 'extractor-native'),
    ProviderStatus(name: 'Streamruby', domain: 'streamruby.com', type: 'extractor-native'),
    ProviderStatus(name: 'VidNest', domain: 'vidnest.fun', type: 'extractor-native'),
    ProviderStatus(name: 'StreamUp', domain: 'strmup.to', type: 'extractor-native'),
    ProviderStatus(name: 'Vidara', domain: 'vidara.to', type: 'extractor-native'),
    ProviderStatus(name: 'VidHide', domain: 'dhtpre.com', type: 'extractor-native'),
    ProviderStatus(name: 'Nekostream', domain: 'vidtube.site', type: 'extractor-native'),
    ProviderStatus(name: 'Vidora', domain: 'vidora.stream', type: 'extractor-native'),
    ProviderStatus(name: 'Vidsonic', domain: 'vidsonic.net', type: 'extractor-native'),
    ProviderStatus(name: 'Vtube', domain: 'vtbe.to', type: 'extractor-native'),
    ProviderStatus(name: 'Okru', domain: 'ok.ru', type: 'extractor-native'),
    ProviderStatus(name: 'Dailymotion', domain: 'dailymotion.com', type: 'extractor-native'),
    ProviderStatus(name: 'Moflix', domain: 'moflix-stream.xyz', type: 'extractor-native'),
    ProviderStatus(name: 'Community', domain: 'streamingunity.dog', type: 'extractor-native'),
    ProviderStatus(name: 'Frembed', domain: 'frembed.click', type: 'extractor-native'),
    ProviderStatus(name: 'Vidrock', domain: 'vidrock.net', type: 'extractor-native'),
    ProviderStatus(name: 'GenericMedia', domain: '-', type: 'extractor-native'),
  ];

  List<ProviderStatus> _serverResults = [];
  List<ProviderStatus> _extractorResults = [];
  bool _testingServers = false;
  bool _testingExtractors = false;
  bool _serversComplete = false;
  bool _extractorsComplete = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _serverResults = _servers.map((s) => s.copyWith()).toList();
    _extractorResults = _extractors.map((s) => s.copyWith()).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Runtime health testing ──

  static const String _probeTmdbId = '550';
  static const String _probeTitle = 'اختبار تشغيل المصادر';

  String _normalizeName(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  bool _matchesName(String provider, String value) {
    final a = _normalizeName(provider);
    final b = _normalizeName(value);
    if (a.isEmpty || b.isEmpty) return false;
    return a == b || a.contains(b) || b.contains(a);
  }

  Future<void> _testAllServers() => _testRuntimePipeline();

  Future<void> _testAllExtractors() => _testRuntimePipeline();

  Future<void> _testRuntimePipeline() async {
    if (_testingServers || _testingExtractors) return;
    setState(() {
      _testingServers = true;
      _testingExtractors = true;
      _serversComplete = false;
      _extractorsComplete = false;
      _serverResults = _servers.map((s) => s.copyWith()).toList();
      _extractorResults = _extractors.map((s) => s.copyWith()).toList();
    });

    // First check only basic network reachability. A reachable homepage is
    // deliberately NOT marked healthy: the old screen treated any HTTP < 500
    // as "سليم", which is why it looked green while playback still failed.
    final dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 8)
      ..options.receiveTimeout = const Duration(seconds: 8);

    final checks = <Future<void>>[];
    for (int i = 0; i < _serverResults.length; i++) {
      checks.add(_testDomainReachability(dio, i, isServer: true));
    }
    for (int i = 0; i < _extractorResults.length; i++) {
      checks.add(_testDomainReachability(dio, i, isServer: false));
    }
    await Future.wait(checks);
    dio.close();

    // On Android we can run the exact same native resolver used by playback
    // against a known TMDB movie. Only a URL that survives extractor-level
    // validation is allowed to become green.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final streams = await NativeStreamExtractor.resolveStreams(
        tmdbId: _probeTmdbId,
        isMovie: true,
        title: _probeTitle,
      );

      if (mounted) {
        setState(() {
          for (int i = 0; i < _serverResults.length; i++) {
            final provider = _serverResults[i];
            final attempts = streams.where((stream) {
              final server = stream['server']?.toString() ?? '';
              final source = stream['source']?.toString() ?? '';
              return _matchesName(provider.name, server) ||
                  _matchesName(provider.name, source);
            }).toList();
            if (attempts.isEmpty) continue;
            final success = attempts.any((stream) =>
                stream['available'] == true &&
                (stream['url']?.toString().isNotEmpty ?? false));
            _serverResults[i] = provider.copyWith(
              healthy: success,
              error: success ? null : 'لم ينتج بثًا صالحًا في اختبار التشغيل',
            );
          }

          for (int i = 0; i < _extractorResults.length; i++) {
            final provider = _extractorResults[i];
            final success = streams.any((stream) {
              if (stream['available'] != true ||
                  !(stream['url']?.toString().isNotEmpty ?? false)) {
                return false;
              }
              final source = stream['source']?.toString() ?? '';
              return _matchesName(provider.name, source);
            });
            if (success) {
              _extractorResults[i] = provider.copyWith(
                healthy: true,
                error: null,
              );
            }
          }
        });
      }
    }

    if (mounted) {
      setState(() {
        _testingServers = false;
        _testingExtractors = false;
        _serversComplete = true;
        _extractorsComplete = true;
      });
    }
  }

  Future<void> _testDomainReachability(
    Dio dio,
    int index, {
    required bool isServer,
  }) async {
    final results = isServer ? _serverResults : _extractorResults;
    final provider = results[index];
    final domain = provider.domain;

    if (domain == '-' || domain.isEmpty) {
      if (mounted) {
        setState(() {
          final list = isServer ? _serverResults : _extractorResults;
          list[index] = provider.copyWith(
            healthy: null,
            error: 'لا يوجد نطاق مباشر للاختبار',
          );
        });
      }
      return;
    }

    final sw = Stopwatch()..start();
    try {
      final response = await dio.get(
        'https://$domain',
        options: Options(
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/124 Mobile Safari/537.36',
          },
          followRedirects: true,
          validateStatus: (_) => true,
        ),
      );
      sw.stop();
      final code = response.statusCode ?? 0;
      final reachable = code > 0 && code < 500;
      if (mounted) {
        setState(() {
          final list = isServer ? _serverResults : _extractorResults;
          list[index] = provider.copyWith(
            // Reachability alone is intentionally "unknown", not green.
            healthy: reachable ? null : false,
            error: reachable
                ? 'النطاق متاح؛ لم يُثبت بث فعلي بعد'
                : 'تعذر الوصول إلى النطاق',
            responseMs: sw.elapsedMilliseconds,
          );
        });
      }
    } catch (_) {
      sw.stop();
      if (mounted) {
        setState(() {
          final list = isServer ? _serverResults : _extractorResults;
          list[index] = provider.copyWith(
            healthy: false,
            error: 'تعذر الوصول إلى النطاق',
            responseMs: sw.elapsedMilliseconds,
          );
        });
      }
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'حالة المصادر',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_testingServers || _testingExtractors)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _testAllServers();
                _testAllExtractors();
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'الخوادم'),
            Tab(text: 'المستخرجات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServersTab(),
          _buildExtractorsTab(),
        ],
      ),
    );
  }

  // ── Servers tab ──

  Widget _buildServersTab() {
    final healthyCount = _serverResults.where((s) => s.healthy == true).length;
    final unhealthyCount = _serverResults.where((s) => s.healthy == false).length;
    final pendingCount = _serverResults.where((s) => s.healthy == null).length;

    return Column(
      children: [
        _buildSummaryCard(healthyCount, unhealthyCount, pendingCount),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _serverResults.length,
            itemBuilder: (context, index) => _buildProviderCard(_serverResults[index]),
          ),
        ),
        if (!_serversComplete && !_testingServers)
          _buildTestButton('اختبار تشغيل فعلي', _testAllServers),
      ],
    );
  }

  // ── Extractors tab ──

  Widget _buildExtractorsTab() {
    final healthyCount = _extractorResults.where((s) => s.healthy == true).length;
    final unhealthyCount = _extractorResults.where((s) => s.healthy == false).length;
    final pendingCount = _extractorResults.where((s) => s.healthy == null).length;

    // Group by type
    final webviewExtractors = _extractorResults.where((e) => e.type == 'extractor-webview').toList();
    final apiExtractors = _extractorResults.where((e) => e.type == 'extractor-api').toList();
    final nativeExtractors = _extractorResults.where((e) => e.type == 'extractor-native').toList();

    return Column(
      children: [
        _buildSummaryCard(healthyCount, unhealthyCount, pendingCount),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (webviewExtractors.isNotEmpty) ...[
                _buildSectionHeader('معتمدة على WebView', Icons.web, webviewExtractors),
                ...webviewExtractors.map((e) => _buildProviderCard(e)),
              ],
              if (apiExtractors.isNotEmpty) ...[
                _buildSectionHeader('واجهة API / عامل', Icons.api, apiExtractors),
                ...apiExtractors.map((e) => _buildProviderCard(e)),
              ],
              if (nativeExtractors.isNotEmpty) ...[
                _buildSectionHeader('أصلي / HTTP', Icons.code, nativeExtractors),
                ...nativeExtractors.map((e) => _buildProviderCard(e)),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
        if (!_extractorsComplete && !_testingExtractors)
          _buildTestButton('اختبار تشغيل فعلي', _testAllExtractors),
      ],
    );
  }

  // ── Shared widgets ──

  Widget _buildSummaryCard(int healthy, int unhealthy, int pending) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('بث صالح', healthy, Colors.green),
          _buildSummaryItem('فشل', unhealthy, Colors.red),
          _buildSummaryItem('غير مؤكد', pending, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, List<ProviderStatus> items) {
    final healthy = items.where((s) => s.healthy == true).length;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '$healthy/${items.length}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ProviderStatus provider) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (provider.healthy == true) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = provider.responseMs != null
          ? 'بث صالح • ${provider.responseMs}ms'
          : 'بث صالح';
    } else if (provider.healthy == false) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = provider.error ?? 'فشل';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusText = provider.error ??
          (provider.domain == '-' ? 'لا يوجد نطاق' : 'لم يُختبر');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.domain == '-' ? 'لا يوجد نطاق' : provider.domain,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
