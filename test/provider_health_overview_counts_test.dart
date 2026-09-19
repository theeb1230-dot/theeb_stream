import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('overview group counters account for every displayed source', () {
    final source =
        File('lib/screens/provider_health_overview_screen.dart').readAsStringSync();

    expect(
      source,
      contains('final uncertain = items.length - resolved - failed;'),
    );
    expect(source, contains('رابط مستخرج \$resolved • فشل \$failed • غير مؤكد \$uncertain • المجموع \${items.length}'));
    expect(source, isNot(contains('مستخرج \$resolved • فشل \$failed • الإجمالي \${items.length}')));
  });

  test('overview never paints extracted or reachable states green', () {
    final source =
        File('lib/screens/provider_health_overview_screen.dart').readAsStringSync();

    expect(source, contains("SourceProbeState.resolved =>\n        (Colors.amber, Icons.link_rounded, 'مستخرج فقط')"));
    expect(source, contains("SourceProbeState.reachable =>\n        (Colors.grey, Icons.help_outline_rounded, 'غير مؤكد')"));
    expect(source, isNot(contains('SourceProbeState.resolved =>\n        (Colors.green')));
  });
}
