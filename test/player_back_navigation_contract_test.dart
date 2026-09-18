import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('player does not trap platform Back', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('return PopScope('));
    expect(source, contains('canPop: true,'));
    expect(source, isNot(contains('canPop: false,')));
    expect(source, contains('if (didPop) {'));
    expect(source, contains('_cancelBufferingWatchdog();'));
    expect(source, contains('unawaited(_saveProgress());'));
  });

  test('modal pickers use their own navigator route so Back closes them first', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(
      RegExp(r'showModalBottomSheet<void>\(').allMatches(source).length,
      greaterThanOrEqualTo(3),
    );
    expect(source, contains('Navigator.of(sheetContext).pop();'));
  });

  test('explicit player exit remains idempotent and persists progress', () {
    final source =
        File('lib/screens/m3u8_video_player_screen.dart').readAsStringSync();

    expect(source, contains('if (_isLeaving) return;'));
    expect(source, contains('_isLeaving = true;'));
    expect(source, contains('await _saveProgress();'));
    expect(source, contains('Navigator.of(context).pop(true);'));
  });
}
