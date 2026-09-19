import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV exit dialog has deterministic bidirectional D-Pad traversal', () {
    final source = File(
      'android/tvapp/src/main/java/com/maxstream/app/ui/shell/MainActivity.kt',
    ).readAsStringSync();

    final dialogStart = source.indexOf('private fun ExitDialog');
    expect(dialogStart, greaterThanOrEqualTo(0));
    final dialog = source.substring(dialogStart);

    final cancelStart = dialog.indexOf('.focusRequester(cancelFocus)');
    final confirmStart = dialog.indexOf('.focusRequester(confirmFocus)');
    expect(cancelStart, greaterThanOrEqualTo(0));
    expect(confirmStart, greaterThan(cancelStart));

    final cancelButton = dialog.substring(cancelStart, confirmStart);
    final confirmButton = dialog.substring(confirmStart);

    expect(cancelButton, contains('left = confirmFocus'));
    expect(cancelButton, contains('right = confirmFocus'));
    expect(confirmButton, contains('left = cancelFocus'));
    expect(confirmButton, contains('right = cancelFocus'));
  });
}
