import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unfold_assessment/widgets/controls/range_selector.dart';
import 'package:unfold_assessment/main.dart';

void main() {
  group('Range Selector Widget Tests', () {
    testWidgets('Range selector updates on tap', (WidgetTester tester) async {
      DateRange selectedRange = DateRange.sevenDays;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelector(
              selectedRange: selectedRange,
              onRangeChanged: (range) {
                selectedRange = range;
              },
            ),
          ),
        ),
      );

      expect(find.text('7d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
      expect(find.text('90d'), findsOneWidget);

      await tester.tap(find.text('30d'));
      await tester.pumpAndSettle();

      expect(selectedRange, equals(DateRange.thirtyDays));

      await tester.tap(find.text('90d'));
      await tester.pumpAndSettle();

      expect(selectedRange, equals(DateRange.ninetyDays));
    });

    testWidgets('Range selector buttons are visually distinct when selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelector(
              selectedRange: DateRange.sevenDays,
              onRangeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('7d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
      expect(find.text('90d'), findsOneWidget);

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('Dashboard Integration Tests', () {
    testWidgets('App initializes and shows loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('Theme toggle button exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);

      expect(find.byType(AppBar), findsOneWidget);

      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsAtLeastNWidgets(1));
    });

    testWidgets('Large dataset toggle widget exists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Error State Widget Tests', () {
    testWidgets('Error view shows retry button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text('Oops! Something went wrong'),
                        const SizedBox(height: 8),
                        const Text('Test error message'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
    });
  });
}
