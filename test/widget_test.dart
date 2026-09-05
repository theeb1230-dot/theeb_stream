import 'package:flutter_test/flutter_test.dart';
import 'package:theeb_stream/main.dart';

void main() {
  testWidgets('Arabic startup error surface is renderable', (tester) async {
    await tester.pumpWidget(const ErrorApp(error: 'اختبار'));

    expect(find.textContaining('تعذر تشغيل التطبيق'), findsOneWidget);
    expect(find.textContaining('اختبار'), findsOneWidget);
  });
}
