// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas1_crud/main.dart';

void main() {
  testWidgets('FloatingActionButton opens Add Password dialog', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PasswordManagerApp());

    // Verify that the title of the main screen is visible.
    expect(find.text('Password Manager'), findsOneWidget);

    // Tap the '+' icon and trigger a frame to open the dialog.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the 'Tambah Password' dialog is shown.
    expect(find.text('Tambah Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Tambah'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Batal'), findsOneWidget);
  });
}
