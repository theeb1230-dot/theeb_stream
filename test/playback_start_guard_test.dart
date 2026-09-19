import 'package:flutter_test/flutter_test.dart';
import 'package:theeb_stream/services/playback_start_guard.dart';

void main() {
  group('PlaybackStartGuard', () {
    const guard = PlaybackStartGuard(
      timeout: Duration(milliseconds: 80),
      pollInterval: Duration(milliseconds: 5),
      minimumProgress: Duration(milliseconds: 20),
    );

    test('confirms only after sustained playback position advances', () async {
      var reads = 0;
      final confirmed = await guard.confirm(
        position: () {
          reads++;
          return Duration(milliseconds: reads * 10);
        },
        hasError: () => false,
        isPlaying: () => true,
      );

      expect(confirmed, isTrue);
      expect(reads, greaterThanOrEqualTo(4));
    });

    test('rejects initialized player that remains stalled', () async {
      final confirmed = await guard.confirm(
        position: () => Duration.zero,
        hasError: () => false,
        isPlaying: () => true,
      );

      expect(confirmed, isFalse);
    });

    test('rejects a one-off position jump followed by a stall', () async {
      var reads = 0;
      final confirmed = await guard.confirm(
        position: () {
          reads++;
          if (reads == 1) return Duration.zero;
          return const Duration(milliseconds: 600);
        },
        hasError: () => false,
        isPlaying: () => true,
      );

      expect(confirmed, isFalse);
    });

    test('fails immediately when player reports an error', () async {
      final confirmed = await guard.confirm(
        position: () => Duration.zero,
        hasError: () => true,
        isPlaying: () => false,
      );

      expect(confirmed, isFalse);
    });

    test('fails when owner is disposed while waiting', () async {
      final confirmed = await guard.confirm(
        position: () => Duration.zero,
        hasError: () => false,
        isPlaying: () => true,
        isDisposed: () => true,
      );

      expect(confirmed, isFalse);
    });
  });
}
