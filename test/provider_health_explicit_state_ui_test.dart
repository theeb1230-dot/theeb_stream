import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider health screen uses explicit source states end to end', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();

    expect(source, contains("import '../models/source_health_state.dart';"));
    expect(source, contains('final SourceHealthState state;'));
    expect(source, isNot(contains('final bool? healthy;')));
    expect(source, contains('s.state.isPlaybackConfirmed'));
    expect(source, contains('s.state.isFailure'));
  });

  test('cards expose the five truthful Arabic outcomes without ellipsis', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();

    for (final state in <String>[
      'SourceHealthState.playbackStarted',
      'SourceHealthState.urlExtracted',
      'SourceHealthState.failed',
      'SourceHealthState.webViewRequired',
      'SourceHealthState.unsupported',
    ]) {
      expect(source, contains(state), reason: state);
    }
    expect(source, contains('state.arabicLabel'));
    expect(source, contains('softWrap: true'));
    expect(source, isNot(contains('TextOverflow.ellipsis')));
  });

  test('runtime extracted URLs stay extracted rather than failed or green', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();

    expect(source, contains('sourceHealthStateFromRuntime('));
    expect(
      source,
      contains('states.contains(SourceHealthState.urlExtracted)'),
    );
    expect(
      source,
      contains('? SourceHealthState.urlExtracted'),
    );
    expect(
      source,
      contains("stream['playbackStarted'] == true"),
    );
  });

  test('WebView reachability stays unverified rather than green', () {
    final source =
        File('lib/screens/provider_health_screen.dart').readAsStringSync();

    expect(
      source,
      contains(
        "provider.type == 'extractor-webview'\n                    ? SourceHealthState.webViewRequired",
      ),
    );
    expect(source, contains('SourceHealthState.notTested'));
  });
}
