import 'package:flutter_test/flutter_test.dart';
import 'package:sporthub/main.dart';

void main() {
  testWidgets('SportHub app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SportHubApp());
    await tester.pump();

    expect(find.text('SportHub'), findsWidgets);
  });
}
