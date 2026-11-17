import 'package:flutter_test/flutter_test.dart';
import 'package:sharo_app/main.dart';

void main() {
  testWidgets('Sharo App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SharoApp());
    expect(find.byType(SharoApp), findsOneWidget);
  });
}
