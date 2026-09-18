import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source health requires explicit playback-start proof', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();
    final stateModel =
        File('lib/models/source_health_state.dart').readAsStringSync();

    // Both server and extractor runtime paths feed the explicit state mapper.
    // Keep this contract focused on the behavior boundary instead of copying
    // a particular UI implementation literal.
    expect(
      RegExp(r"stream\['playbackStarted'\]").allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
    expect(
      source,
      contains("stream['playbackStarted'] == true"),
    );
    expect(
      source,
      contains("playbackStarted: stream['playbackStarted'] == true"),
    );
    expect(source, contains('state.arabicLabel'));
    expect(
      source,
      contains('SourceHealthState.playbackStarted => Colors.green'),
    );
    expect(
      stateModel,
      contains("SourceHealthState.playbackStarted => 'بدأ فعليًا'"),
    );
  });

  test('extractor group counters describe every displayed item', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();

    expect(source, contains('final started ='));
    expect(source, contains('final failed ='));
    expect(source, contains('final uncertain = items.length - started - failed;'));
    expect(
      source,
      contains(
        r"'بدأ $started · فشل $failed · غير مؤكد $uncertain · المجموع ${items.length}'",
      ),
    );
    expect(source, isNot(contains(r"'$healthy/${items.length}'")));
  });
}
