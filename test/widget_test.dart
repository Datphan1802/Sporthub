import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sporthub/views/splash/splash_screen.dart';

void main() {
  testWidgets('SportHub splash smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SplashScreen(onInitialized: () {})),
    );
    await tester.pump();

    expect(find.text('SportHub'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  });
}
