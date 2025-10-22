import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unfold_assessment/main.dart';

void main() {
  testWidgets('App smoke test - verifies basic structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
