// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:katholiks/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KatholiksApp());

    // Verify that we have the splash screen with the app name
    expect(find.text('Katholiks'), findsOneWidget);

    // Wait for the splash screen animation and navigation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // After splash, we should see the login screen
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
