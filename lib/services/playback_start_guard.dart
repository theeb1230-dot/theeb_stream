import 'dart:async';

/// Confirms that playback has genuinely started instead of treating a
/// successful player initialization as proof that media is advancing.
///
/// The caller supplies tiny read-only callbacks so this guard stays independent
/// of any concrete player plugin and remains straightforward to unit test.
/// Success requires an active playing state plus sustained measurable position
/// progress. A single position jump is not enough: some players briefly report
/// a seek/timeline update before a stalled stream settles back into buffering.
class PlaybackStartGuard {
  const PlaybackStartGuard({
    this.timeout = const Duration(seconds: 12),
    this.pollInterval = const Duration(milliseconds: 250),
    this.minimumProgress = const Duration(milliseconds: 500),
    this.requiredProgressSamples = 2,
  }) : assert(requiredProgressSamples > 0);

  final Duration timeout;
  final Duration pollInterval;
  final Duration minimumProgress;
  final int requiredProgressSamples;

  Future<bool> confirm({
    required Duration Function() position,
    required bool Function() hasError,
    required bool Function() isPlaying,
    bool Function()? isDisposed,
  }) async {
    final startedAt = DateTime.now();
    final baseline = position();
    var lastPosition = baseline;
    var consecutiveProgressSamples = 0;

    while (DateTime.now().difference(startedAt) < timeout) {
      if (isDisposed?.call() == true || hasError()) return false;

      final currentPosition = position();
      final advancedBy = currentPosition - baseline;
      final advancedSinceLastSample = currentPosition > lastPosition;
      if (isPlaying() &&
          advancedBy >= minimumProgress &&
          advancedSinceLastSample) {
        consecutiveProgressSamples++;
        if (consecutiveProgressSamples >= requiredProgressSamples) return true;
      } else {
        // Require continuity. A one-off timeline/seek jump followed by a stall
        // must never promote a source to "started".
        consecutiveProgressSamples = 0;
      }
      lastPosition = currentPosition;

      await Future<void>.delayed(pollInterval);
    }

    return false;
  }
}
