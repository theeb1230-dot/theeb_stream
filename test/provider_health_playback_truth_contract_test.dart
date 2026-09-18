import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source health requires explicit playback-start proof', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();

    // Both server and extractor success paths must depend on playbackStarted.
    // The server path uses an expression; the extractor path uses an explicit
    // fail-closed guard, so do not couple this contract to identical syntax.
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
      contains("stream['playbackStarted'] != true"),
    );
    expect(source, contains("statusText = 'بدأ فعليًا';"));
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
