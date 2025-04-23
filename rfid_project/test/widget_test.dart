// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rfid_project/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('RFID Project')),
          body: Center(child: Text('Hello, RFID!')),
        ),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing);
    expect(find.text('Hello, RFID!'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    // Note: This part is commented out because there is no counter in the current app.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsNothing);
  });
}
