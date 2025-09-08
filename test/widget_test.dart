// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qns/main.dart'; // Make sure this file exports DailyQApp

void main() {
  testWidgets('App instantiates without crashing', (WidgetTester tester) async {
    // Build the app using the actual root widget from your app
    await tester.pumpWidget(const DailyQApp());

    // Let any initial streams settle
    await tester.pumpAndSettle();

    // At this point, since authStateChanges is still waiting,
    // you should see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
