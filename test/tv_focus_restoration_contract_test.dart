import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV Details back restores originating content focus instead of sidebar', () {
    final source = File(
      'android/tvapp/src/main/java/com/maxstream/app/ui/shell/MainActivity.kt',
    ).readAsStringSync();

    final detailsRouteStart = source.indexOf('composable(Screen.Details.route)');
    final playerRouteStart = source.indexOf('composable(Screen.Player.route)');
    expect(detailsRouteStart, greaterThanOrEqualTo(0));
    expect(playerRouteStart, greaterThan(detailsRouteStart));

    final detailsRoute = source.substring(detailsRouteStart, playerRouteStart);
    expect(detailsRoute, contains('deepNavController.popBackStack()'));
    expect(
      detailsRoute,
      isNot(contains('appState.updateFocusOnSidebar(true)')),
      reason:
          'Details -> list must restore the originating card/row via deepNavReturnTick, not steal focus into the sidebar.',
    );

    expect(source, contains('deepNavReturnTick++'));
    expect(
      RegExp(r'restoreFocusKey\s*=\s*deepNavReturnTick').allMatches(source).length,
      greaterThanOrEqualTo(5),
      reason:
          'All content tabs that launch deep navigation must observe the shared restore tick.',
    );
  });
}
