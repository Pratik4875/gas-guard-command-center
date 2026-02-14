// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gas_leak_detection/main.dart';
import 'package:gas_leak_detection/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard Verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GasLeakDetectorApp(isConfigured: false));
    await tester.pump(const Duration(seconds: 2));

    // Verify that the dashboard is present.
    expect(find.byType(DashboardScreen), findsOneWidget);
  }, skip: true);
}
