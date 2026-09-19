import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV exit dialog keeps focus requesters stable across recomposition', () {
    final source = File(
      'android/tvapp/src/main/java/com/maxstream/app/ui/shell/MainActivity.kt',
    ).readAsStringSync();

    final dialogStart = source.indexOf('private fun ExitDialog');
    expect(dialogStart, greaterThanOrEqualTo(0));
    final dialog = source.substring(dialogStart);

    expect(dialog, contains('val cancelFocus = remember { FocusRequester() }'));
    expect(dialog, contains('val confirmFocus = remember { FocusRequester() }'));
    expect(dialog, contains('LaunchedEffect(Unit) { cancelFocus.requestFocus() }'));
    expect(
      dialog,
      isNot(contains('val cancelFocus = FocusRequester()')),
      reason:
          'A recreated requester can detach from the button while LaunchedEffect keeps the old instance, stranding TV focus.',
    );
    expect(
      dialog,
      isNot(contains('val confirmFocus = FocusRequester()')),
    );
  });
}
