import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playback recovery blacklists failed media URLs for the session', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('final Set<String> _failedMediaUrls = {};'));
    expect(source, contains('_failedMediaUrls.add(url);'));
    expect(source, contains('_failedMediaUrls.add(fallbackUrl);'));
    expect(
      source,
      contains("!_failedMediaUrls.contains(s['url']?.toString() ?? '')"),
    );
    expect(source, contains('_failedMediaUrls.contains(fallbackUrl)'));
  });

  test('new media load resets both server and URL failure state', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(
      source,
      matches(
        RegExp(
          r'_failedServerKeys\.clear\(\);\s*_failedMediaUrls\.clear\(\);',
        ),
      ),
    );
  });

  test('fallback still resumes from the last stable playback position', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('position: _lastStablePosition'));
  });
}
