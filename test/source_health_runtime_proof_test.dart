import 'package:flutter_test/flutter_test.dart';
import 'package:theeb_stream/models/source_health_state.dart';

void main() {
  group('sourceHealthStateFromRuntime', () {
    test('playback proof wins over a stale availability flag', () {
      expect(
        sourceHealthStateFromRuntime(
          available: false,
          playbackStarted: true,
          url: 'https://media.example/stream.m3u8',
        ),
        SourceHealthState.playbackStarted,
      );
    });

    test('URL plus availability is extracted only, never playback success', () {
      expect(
        sourceHealthStateFromRuntime(
          available: true,
          playbackStarted: false,
          url: 'https://media.example/stream.m3u8',
        ),
        SourceHealthState.urlExtracted,
      );
    });

    test('playback flag without a URL fails closed', () {
      expect(
        sourceHealthStateFromRuntime(
          available: true,
          playbackStarted: true,
          url: null,
        ),
        SourceHealthState.failed,
      );
    });

    test('unsupported takes precedence over every runtime hint', () {
      expect(
        sourceHealthStateFromRuntime(
          available: true,
          playbackStarted: true,
          url: 'https://media.example/stream.m3u8',
          supported: false,
        ),
        SourceHealthState.unsupported,
      );
    });

    test('WebView-required state remains unverified when playback is absent', () {
      expect(
        sourceHealthStateFromRuntime(
          available: false,
          playbackStarted: false,
          url: null,
          requiresWebView: true,
        ),
        SourceHealthState.webViewRequired,
      );
    });
  });
}
