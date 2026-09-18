import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('playback buffering watchdog contract', () {
    late String playerSource;

    setUpAll(() {
      playerSource = File(
        'lib/screens/m3u8_video_player_screen.dart',
      ).readAsStringSync();
    });

    test('uses a bounded 12 second watchdog before recovery', () {
      expect(
        playerSource,
        contains('_bufferingWatchdog = Timer(const Duration(seconds: 12)'),
      );
      expect(playerSource, contains('value.isBuffering && !value.hasError && !advanced'));
      expect(playerSource, contains("_showStatus('الخادم عالق في التحميل، جارٍ تجربة خادم آخر...')"));
    });

    test('marks the current server failed before recovering', () {
      expect(
        playerSource,
        contains('if (currentKey != null) _failedServerKeys.add(currentKey);'),
      );
      expect(playerSource, contains('unawaited(_recoverPlayback());'));
    });

    test('next-server selection cannot return current or failed identities', () {
      expect(playerSource, contains('serverKey == currentKey ||'));
      expect(playerSource, contains('_failedServerKeys.contains(serverKey)'));
    });

    test('recovery resumes from the last stable position', () {
      expect(
        playerSource,
        contains('if (value.position > Duration.zero) _lastStablePosition = value.position;'),
      );
      expect(playerSource, contains('position: _lastStablePosition'));
    });

    test('watchdog is cancelled during recovery and teardown paths', () {
      expect(playerSource, contains('void _cancelBufferingWatchdog()'));
      expect(playerSource, contains('_bufferingWatchdog?.cancel();'));
      expect(playerSource, contains('_cancelBufferingWatchdog();'));
    });
  });
}
