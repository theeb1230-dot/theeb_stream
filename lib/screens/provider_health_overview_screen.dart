import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/direct_m3u8_service.dart';
import '../services/native_stream_extractor.dart';
import '../services/theeb_arab_server_registry.dart';

enum SourceProbeState { unknown, reachable, resolved, failed, unsupported }

class SourceProbe {
  final String name;
  final String domain;
  final String type;
  final SourceProbeState state;
  final String message;
  final int? responseMs;

  const SourceProbe({
    required this.name,
    required this.domain,
    required this.type,
    this.state = SourceProbeState.unknown,
    this.message = 'لم يُختبر بعد',
    this.responseMs,
  });

  SourceProbe copyWith({
    SourceProbeState? state,
    String? message,
    int? responseMs,
  }) {
    return SourceProbe(
      name: name,
      domain: domain,
      type: type,
      state: state ?? this.state,
      message: message ?? this.message,
      responseMs: responseMs ?? this.responseMs,
    );
  }
}

/// شاشة تشخيص صادقة: الوصول إلى الدومين أو حتى استخراج URL لا يعني أن
/// الفيديو بدأ فعليًا. لذلك لا تعرض هذه الشاشة أي مصدر بالأخضر إلا إذا توفر
/// لاحقًا دليل player-start من مسار التشغيل نفسه.
class ProviderHealthOverviewScreen extends StatefulWidget {
  const ProviderHealthOverviewScreen({super.key});

  @override
  State<ProviderHealthOverviewScreen> createState() =>
      _ProviderHealthOverviewScreenState();
}

class _ProviderHealthOverviewScreenState
    extends State<ProviderHealthOverviewScreen>
    with SingleTickerProviderStateMixin {
  static const _probeTmdbId = '550';
  static const _probeTitle = 'اختبار تشغيل المصادر';

  late final TabController _tabs;
  bool _testing = false;

  final List<SourceProbe> _servers = const [
    SourceProbe(name: 'VixSrc', domain: 'vixsrc.to', type: 'server'),
    SourceProbe(name: 'VidLink', domain: 'vidlink.pro', type: 'server'),
    SourceProbe(name: '2Embed', domain: '2embed.cc', type: 'server'),
    SourceProbe(name: 'Videasy', domain: 'player.videasy.to', type: 'server'),
    SourceProbe(name: 'VidFast', domain: 'vidfast.vc', type: 'server'),
    SourceProbe(name: 'VidsrcRu', domain: 'vidsrc.ru', type: 'server'),
    SourceProbe(name: 'Vidrock', domain: 'vidrock.net', type: 'server'),
    SourceProbe(name: 'PrimeSrc', domain: 'primesrc.me', type: 'server'),
  ];

  final List<SourceProbe> _extractors = const [
    SourceProbe(name: 'VidLink', domain: 'vidlink.pro', type: 'webview'),
    SourceProbe(name: 'Mov2Day', domain: 'mov2day.xyz', type: 'webview'),
    SourceProbe(name: 'VidsrcRu', domain: 'vidsrc.ru', type: 'webview'),
    SourceProbe(name: 'StreamWish', domain: 'streamwish.to', type: 'webview'),
    SourceProbe(name: 'VidLove', domain: 'vidlove.cc', type: 'webview'),
    SourceProbe(name: 'VixSrc', domain: 'vixsrc.to', type: 'native'),
    SourceProbe(name: 'Vidsrc', domain: 'vidsrc-embed.ru', type: 'native'),
    SourceProbe(name: 'PrimeSrc', domain: 'primesrc.me', type: 'api'),
    SourceProbe(name: 'Videasy', domain: 'videasy.to', type: 'native'),
    SourceProbe(name: 'VidFast', domain: 'vidfast.vc', type: 'native'),
    SourceProbe(name: 'Voe', domain: 'voe.sx', type: 'native'),
    SourceProbe(name: 'Streamtape', domain: 'streamtape.com', type: 'native'),
    SourceProbe(name: '2Embed', domain: '2embed.cc', type: 'native'),
    SourceProbe(name: 'Videm', domain: 'videm.xyz', type: 'native'),
    SourceProbe(name: 'Filemoon', domain: 'filemoon.sx', type: 'native'),
    SourceProbe(name: 'Dood', domain: 'dood.pm', type: 'native'),
    SourceProbe(name: 'VidMoLy', domain: 'vidmoly.to', type: 'native'),
    SourceProbe(name: 'LuluVdo', domain: 'luluvdo.com', type: 'native'),
    SourceProbe(name: 'MixDrop', domain: 'mixdrop.to', type: 'native'),
    SourceProbe(name: 'Supervideo', domain: 'supervideo.cc', type: 'native'),
    SourceProbe(name: 'Rabbitstream', domain: 'rabbitstream.net', type: 'native'),
    SourceProbe(name: 'Megacloud', domain: 'megacloud.club', type: 'native'),
    SourceProbe(name: 'GxPlayer', domain: 'gxplayer.net', type: 'native'),
    SourceProbe(name: 'Veev', domain: 'veev.to', type: 'native'),
    SourceProbe(name: 'Vidplay', domain: 'vidplay.online', type: 'native'),
    SourceProbe(name: 'Streamruby', domain: 'streamruby.com', type: 'native'),
    SourceProbe(name: 'VidNest', domain: 'vidnest.fun', type: 'native'),
    SourceProbe(name: 'StreamUp', domain: 'strmup.to', type: 'native'),
    SourceProbe(name: 'Vidara', domain: 'vidara.to', type: 'native'),
    SourceProbe(name: 'VidHide', domain: 'dhtpre.com', type: 'native'),
    SourceProbe(name: 'Nekostream', domain: 'vidtube.site', type: 'native'),
    SourceProbe(name: 'Vidora', domain: 'vidora.stream', type: 'native'),
    SourceProbe(name: 'Vidsonic', domain: 'vidsonic.net', type: 'native'),
    SourceProbe(name: 'Vtube', domain: 'vtbe.to', type: 'native'),
    SourceProbe(name: 'Okru', domain: 'ok.ru', type: 'native'),
    SourceProbe(name: 'Dailymotion', domain: 'dailymotion.com', type: 'native'),
    SourceProbe(name: 'Moflix', domain: 'moflix-stream.xyz', type: 'native'),
    SourceProbe(name: 'Community', domain: 'streamingunity.dog', type: 'native'),
    SourceProbe(name: 'Frembed', domain: 'frembed.click', type: 'native'),
    SourceProbe(name: 'Vidrock', domain: 'vidrock.net', type: 'native'),
    SourceProbe(
      name: 'GenericMedia',
      domain: '-',
      type: 'native',
      state: SourceProbeState.unsupported,
      message: 'مستخرج عام بلا نطاق مستقل',
    ),
  ];

  late List<SourceProbe> _serverResults;
  late List<SourceProbe> _extractorResults;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _serverResults = List.of(_servers);
    _extractorResults = List.of(_extractors);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  bool _matches(String a, String b) {
    final aa = _normalize(a);
    final bb = _normalize(b);
    return aa.isNotEmpty && bb.isNotEmpty &&
        (aa == bb || aa.contains(bb) || bb.contains(aa));
  }

  Future<void> _refresh() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _serverResults = List.of(_servers);
      _extractorResults = List.of(_extractors);
    });

    final dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 8)
      ..options.receiveTimeout = const Duration(seconds: 8);
    try {
      await Future.wait([
        for (var i = 0; i < _serverResults.length; i++)
          _probeDomain(dio, i, server: true),
        for (var i = 0; i < _extractorResults.length; i++)
          _probeDomain(dio, i, server: false),
      ]);
      await _probeResolver();
    } finally {
      dio.close(force: true);
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _probeDomain(Dio dio, int index, {required bool server}) async {
    final list = server ? _serverResults : _extractorResults;
    final item = list[index];
    if (item.domain == '-') return;
    final sw = Stopwatch()..start();
    try {
      final response = await dio.get(
        'https://${item.domain}',
        options: Options(
          followRedirects: true,
          validateStatus: (_) => true,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/124 Mobile Safari/537.36',
          },
        ),
      );
      sw.stop();
      final code = response.statusCode ?? 0;
      final reachable = code > 0 && code < 500;
      if (!mounted) return;
      setState(() {
        list[index] = item.copyWith(
          state: reachable ? SourceProbeState.reachable : SourceProbeState.failed,
          message: reachable
              ? 'النطاق متاح فقط؛ لم يثبت بدء تشغيل فيديو فعلي'
              : 'تعذر الوصول إلى النطاق (HTTP $code)',
          responseMs: sw.elapsedMilliseconds,
        );
      });
    } catch (_) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        list[index] = item.copyWith(
          state: SourceProbeState.failed,
          message: 'تعذر الوصول إلى النطاق',
          responseMs: sw.elapsedMilliseconds,
        );
      });
    }
  }

  Future<void> _probeResolver() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    try {
      final streams = defaultTargetPlatform == TargetPlatform.android
          ? await NativeStreamExtractor.resolveStreams(
              tmdbId: _probeTmdbId,
              isMovie: true,
              title: _probeTitle,
            )
          : await DirectM3u8Service.fetchAvailableStreams(
              title: _probeTitle,
              tmdbId: _probeTmdbId,
              isMovie: true,
            );
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _serverResults.length; i++) {
          final item = _serverResults[i];
          final matched = streams.where((stream) {
            final server = stream['server']?.toString() ?? '';
            final source = stream['source']?.toString() ?? '';
            return _matches(item.name, server) || _matches(item.name, source);
          }).toList();
          if (matched.isEmpty) continue;
          final resolved = matched.any((stream) =>
              stream['available'] == true &&
              (stream['url']?.toString().isNotEmpty ?? false));
          _serverResults[i] = item.copyWith(
            state: resolved ? SourceProbeState.resolved : SourceProbeState.failed,
            message: resolved
                ? 'تم استخراج رابط؛ لم يُعتمد صالحًا حتى يبدأ المشغل ويتقدم الفيديو'
                : 'المحلل جرّب المصدر ولم ينتج رابط بث صالحًا',
          );
        }
        for (var i = 0; i < _extractorResults.length; i++) {
          final item = _extractorResults[i];
          final resolved = streams.any((stream) {
            if (stream['available'] != true ||
                !(stream['url']?.toString().isNotEmpty ?? false)) return false;
            return _matches(item.name, stream['source']?.toString() ?? '');
          });
          if (resolved) {
            _extractorResults[i] = item.copyWith(
              state: SourceProbeState.resolved,
              message: 'استخرج رابطًا؛ يحتاج player-start confirmation قبل اعتباره صالحًا',
            );
          }
        }
      });
    } catch (_) {
      // Domain results remain visible; resolver failure must not fabricate green.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('حالة المصادر'),
          actions: [
            if (_testing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                tooltip: 'إعادة الاختبار',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
          ],
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: Colors.redAccent,
            tabs: const [Tab(text: 'الخوادم'), Tab(text: 'المستخرجات')],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildList(_serverResults, showGroups: false),
            _buildList(_extractorResults, showGroups: true),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<SourceProbe> items, {required bool showGroups}) {
    final confirmed = items.where((e) => e.state == SourceProbeState.resolved).length;
    final failed = items.where((e) => e.state == SourceProbeState.failed).length;
    final uncertain = items.where((e) =>
        e.state == SourceProbeState.unknown ||
        e.state == SourceProbeState.reachable ||
        e.state == SourceProbeState.unsupported).length;

    return Column(
      children: [
        _summary(confirmed: 0, resolved: confirmed, failed: failed, uncertain: uncertain),
        if (!showGroups) _theebArabInventoryCard(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              if (showGroups) ...[
                ..._group('معتمدة على WebView', 'webview', items),
                ..._group('واجهة API / عامل', 'api', items),
                ..._group('أصلي / HTTP', 'native', items),
              ] else
                ...items.map(_card),
            ],
          ),
        ),
        if (!_testing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('اختبار المسار الفعلي'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _theebArabInventoryCard() {
    final integrated = TheebArabServerRegistry.integrated.length;
    final pending = TheebArabServerRegistry.pending.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        collapsedIconColor: Colors.grey,
        iconColor: Colors.white,
        title: const Text(
          'مخزون ذيب العرب: 27 خادمًا',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$integrated موجودة أصلًا في Runtime • $pending بانتظار Adapter موثّق',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'الأسماء المسجلة ليست دليل تشغيل. الخادم لا يدخل ترتيب fallback إلا بعد وجود عقد Resolver واختبار Player-Start ناجح.',
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: TheebArabServerRegistry.all.map((server) {
              final active = server.alreadyInRuntime;
              return Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor: active ? Colors.amber.withValues(alpha: 0.15) : Colors.white10,
                side: BorderSide(color: active ? Colors.amber.shade700 : Colors.white12),
                label: Text(
                  server.name,
                  style: TextStyle(color: active ? Colors.amber : Colors.grey.shade400, fontSize: 11),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _group(String title, String type, List<SourceProbe> all) {
    final items = all.where((e) => e.type == type).toList();
    if (items.isEmpty) return const [];
    final resolved = items.where((e) => e.state == SourceProbeState.resolved).length;
    final failed = items.where((e) => e.state == SourceProbeState.failed).length;
    final uncertain = items.length - resolved - failed;
    return [
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              'رابط مستخرج $resolved • فشل $failed • غير مؤكد $uncertain • المجموع ${items.length}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      ...items.map(_card),
    ];
  }

  Widget _summary({
    required int confirmed,
    required int resolved,
    required int failed,
    required int uncertain,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric('بدأ فعليًا', confirmed, Colors.green),
          _metric('رابط مستخرج', resolved, Colors.amber),
          _metric('فشل', failed, Colors.redAccent),
          _metric('غير مؤكد', uncertain, Colors.grey),
        ],
      ),
    );
  }

  Widget _metric(String label, int value, Color color) {
    return Flexible(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _card(SourceProbe item) {
    final (color, icon, label) = switch (item.state) {
      SourceProbeState.resolved =>
        (Colors.amber, Icons.link_rounded, 'مستخرج فقط'),
      SourceProbeState.failed =>
        (Colors.redAccent, Icons.error_rounded, 'فشل'),
      SourceProbeState.reachable =>
        (Colors.grey, Icons.help_outline_rounded, 'غير مؤكد'),
      SourceProbeState.unsupported =>
        (Colors.grey, Icons.block_rounded, 'غير مدعوم مباشرة'),
      SourceProbeState.unknown =>
        (Colors.grey, Icons.help_outline_rounded, 'لم يُختبر'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.domain == '-' ? 'لا يوجد نطاق مستقل' : item.domain,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  item.message,
                  softWrap: true,
                  maxLines: 4,
                  overflow: TextOverflow.visible,
                  style: TextStyle(color: color, fontSize: 13, height: 1.35),
                ),
                if (item.responseMs != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    'زمن الوصول: ${item.responseMs}ms',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
