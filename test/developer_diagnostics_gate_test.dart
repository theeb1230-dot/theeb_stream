import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detailed source diagnostics are developer-mode gated', () {
    final source =
        File('lib/screens/maxstream_more_screen.dart').readAsStringSync();

    expect(source, contains("static const _developerModeKey = 'developer_mode_enabled'"));
    expect(source, contains("prefs.getBool(_developerModeKey) ?? false"));
    expect(source, contains('await prefs.setBool(_developerModeKey, enabled)'));
    expect(source, contains("title: const Text(\n                'وضع المطور'"));
    expect(source, contains('if (_developerMode)'));
    expect(source, contains("title: 'تشخيص المصادر'"));
    expect(source, contains('Focus(\n              child: SwitchListTile('));
    expect(source, contains('autofocus: false'));
  });

  test('ordinary settings no longer expose detailed diagnostics unconditionally', () {
    final source =
        File('lib/screens/maxstream_more_screen.dart').readAsStringSync();

    final gate = source.indexOf('if (_developerMode)');
    final diagnostics = source.indexOf('ProviderHealthOverviewScreen()');
    expect(gate, greaterThanOrEqualTo(0));
    expect(diagnostics, greaterThan(gate));
  });
}
