import 'dart:async';

/// Confirms that playback has genuinely started instead of treating a
/// successful player initialization as proof that media is advancing.
///
/// The caller supplies tiny read-only callbacks so this guard stays independent
/// of any concrete player plugin and remains straightforward to unit test.
class PlaybackStartGuard {
  const PlaybackStartGuard({
    this.timeout = const Duration(seconds: 12),
    this.pollInterval = const Duration(milliseconds: 250),
    this.minimumProgress = const Duration(milliseconds: 500),
  });

  final Duration timeout;
  final Duration pollInterval;
  final Duration minimumProgress;

  Future<bool> confirm({
    required Duration Function() position,
    required bool Function() hasError,
    required bool Function() isPlaying,
    bool Function()? isDisposed,
  }) async {
    final startedAt = DateTime.now();
    final baseline = position();

    while (DateTime.now().difference(startedAt) < timeout) {
      if (isDisposed?.call() == true || hasError()) return false;

      final advancedBy = position() - baseline;
      if (isPlaying() && advancedBy >= minimumProgress) return true;

      await Future<void>.delayed(pollInterval);
    }

    return false;
  }
}
