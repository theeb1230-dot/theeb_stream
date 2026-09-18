import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web embed inventory is never presented as playback-confirmed', () {
    final source = File('lib/services/direct_m3u8_service.dart').readAsStringSync();

    expect(source, contains("'type': 'embed'"));
    expect(source, contains("'available': false"));
    expect(source, contains("'playbackStatus': 'uncertain_webview'"));
    expect(source, contains('if (kIsWeb) return false;'));
  });

  test('worker resolver results cross the stream security boundary', () {
    final source = File('lib/services/direct_m3u8_service.dart').readAsStringSync();

    expect(
      RegExp(r'WebStreamService\.resolveStream\([\s\S]*?StreamSecurity\.sanitizeResolverResult\(result\)'),
      hasMatch(source),
    );
    expect(
      RegExp(r'WebStreamService\.resolveFromServer\([\s\S]*?StreamSecurity\.sanitizeResolverResult\(result\)'),
      hasMatch(source),
    );
  });

  test('transport validation is documented as weaker than player start', () {
    final source = File('lib/services/direct_m3u8_service.dart').readAsStringSync();

    expect(source, contains('A true result means the resource'));
    expect(source, contains('not that playback has started'));
    expect(source, contains('PlaybackStartGuard'));
  });
}
