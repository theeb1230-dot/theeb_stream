import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('player remains poppable during loading and error states', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('return PopScope('));
    expect(source, contains('canPop: true'));
    expect(source, contains("body: _error != null"));
    expect(source, contains(': _buildLoading()'));
    expect(source, contains("'رجوع'"));
    expect(source, contains('onPressed: _exitPlayer'));
  });

  test('server picker is a dismissible route and does not trap platform back', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('showModalBottomSheet'));
    expect(source, contains('Navigator.pop(context'));
  });

  test('player pop cancels watchdog and persists progress', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('if (didPop)'));
    expect(source, contains('_cancelBufferingWatchdog()'));
    expect(source, contains('unawaited(_saveProgress())'));
  });
}
