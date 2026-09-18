import 'package:flutter_test/flutter_test.dart';
import 'package:theeb_stream/models/source_health_state.dart';

void main() {
  test('only confirmed playback is a successful source state', () {
    expect(SourceHealthState.playbackStarted.isPlaybackConfirmed, isTrue);
    for (final state in SourceHealthState.values.where(
      (state) => state != SourceHealthState.playbackStarted,
    )) {
      expect(state.isPlaybackConfirmed, isFalse, reason: state.name);
    }
  });

  test('extracted URL never means playback started', () {
    final state = sourceHealthStateFromRuntime(
      available: true,
      playbackStarted: false,
      url: 'https://example.invalid/video.m3u8',
    );
    expect(state, SourceHealthState.urlExtracted);
    expect(state.arabicLabel, 'رابط مستخرج');
    expect(state.isPlaybackConfirmed, isFalse);
  });

  test('playback start requires available and non-empty URL', () {
    expect(
      sourceHealthStateFromRuntime(
        available: true,
        playbackStarted: true,
        url: 'https://example.invalid/video.m3u8',
      ),
      SourceHealthState.playbackStarted,
    );
    expect(
      sourceHealthStateFromRuntime(
        available: true,
        playbackStarted: true,
        url: '',
      ),
      SourceHealthState.failed,
    );
  });

  test('WebView and unsupported states stay unverified', () {
    expect(
      sourceHealthStateFromRuntime(
        available: false,
        playbackStarted: false,
        url: null,
        requiresWebView: true,
      ),
      SourceHealthState.webViewRequired,
    );
    expect(
      sourceHealthStateFromRuntime(
        available: false,
        playbackStarted: false,
        url: null,
        supported: false,
      ),
      SourceHealthState.unsupported,
    );
    expect(SourceHealthState.webViewRequired.isUnverified, isTrue);
    expect(SourceHealthState.unsupported.isUnverified, isTrue);
  });

  test('Arabic labels cover the complete five user-facing outcomes', () {
    expect(SourceHealthState.playbackStarted.arabicLabel, 'بدأ فعليًا');
    expect(SourceHealthState.urlExtracted.arabicLabel, 'رابط مستخرج');
    expect(SourceHealthState.failed.arabicLabel, 'فشل');
    expect(
      SourceHealthState.webViewRequired.arabicLabel,
      'غير مؤكد / يتطلب WebView',
    );
    expect(SourceHealthState.unsupported.arabicLabel, 'غير مدعوم');
  });
}
