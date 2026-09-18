import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('server picker never equates an extracted URL with started playback', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('final hasResolvedUrl = url.isNotEmpty;'));
    expect(source, contains('final playbackStarted ='));
    expect(source, contains("'بدأ فعليًا · الخادم"));
    expect(source, contains("'رابط مستخرج · لم يبدأ التشغيل بعد'"));
    expect(source, contains("'فشل/غير مؤكد · اضغط لإعادة المحاولة'"));
  });

  test('retry keeps resolver-only results fail-closed', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains("resolved['available'] = false;"));
    expect(source, contains("resolved['playbackStatus'] = 'url_extracted';"));
    expect(
      source,
      isNot(contains("resolved['available'] = true;")),
    );
  });

  test('started state requires initialized player and position progress', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(
      source,
      matches(
        RegExp(
          r'playbackStarted\s*=\s*selected[\s\S]*?isInitialized[\s\S]*?position[\s\S]*?>\s*Duration\.zero',
        ),
      ),
    );
  });
}
