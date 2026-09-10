import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/insights/presentation/insights_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const ProviderScope(
        child: Scaffold(
          body: InsightsScreen(),
        ),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('InsightsScreen UI & Charts Rendering', () {
    testWidgets('Renders header, budget banner, time-range chips, and default donut chart',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Spend Insights'), findsOneWidget);

      // Verify Encouragement Banner
      expect(find.textContaining('12% under budget'), findsOneWidget);
      expect(find.textContaining('Keep it up!'), findsOneWidget);

      // Verify Time-Range Chips
      expect(find.byKey(const Key('time_range_1W')), findsOneWidget);
      expect(find.byKey(const Key('time_range_1M')), findsOneWidget);
      expect(find.byKey(const Key('time_range_3M')), findsOneWidget);
      expect(find.byKey(const Key('time_range_YTD')), findsOneWidget);

      // Verify Donut PieChart
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.byKey(const Key('insights_total_spent_text')), findsOneWidget);
      expect(find.text('\$5310'), findsOneWidget);

      // Verify Category Breakdown List
      expect(find.text('CATEGORY BREAKDOWN'), findsOneWidget);
      expect(find.byKey(const Key('category_item_Travel')), findsOneWidget);
      expect(find.byKey(const Key('category_item_Meals')), findsOneWidget);
      expect(find.byKey(const Key('category_item_Software')), findsOneWidget);
      expect(find.byKey(const Key('category_item_Supplies')), findsOneWidget);

      // Verify AI Bento
      expect(find.text('AI Spend Analysis'), findsOneWidget);
    });

    testWidgets('Tapping chart toggle button switches from PieChart to BarChart',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Initially PieChart is present
      expect(find.byType(PieChart), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.byKey(const Key('toggle_chart_type_button')));
      await tester.pumpAndSettle();

      // Donut PieChart is swapped for category BarChart (along with the trend BarChart)
      expect(find.byType(PieChart), findsNothing);
      expect(find.byType(BarChart), findsAtLeast(2));

      // Tap again to switch back
      await tester.tap(find.byKey(const Key('toggle_chart_type_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
    });
  });

  group('Time-Range Filter Chips & State Updates', () {
    testWidgets('Tapping 1W updates total spend and encouragement banner',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap 1W chip
      await tester.tap(find.byKey(const Key('time_range_1W')));
      await tester.pumpAndSettle();

      // Verify 1W spend: $860, 31% under budget
      expect(find.text('\$860'), findsOneWidget);
      expect(find.textContaining('31% under budget'), findsOneWidget);
      expect(find.byKey(const Key('category_item_Travel')), findsOneWidget);
    });

    testWidgets('Tapping 3M and YTD chips updates aggregations accurately',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap 3M chip
      await tester.tap(find.byKey(const Key('time_range_3M')));
      await tester.pumpAndSettle();

      expect(find.text('\$14820'), findsOneWidget);
      expect(find.textContaining('18% under budget'), findsOneWidget);

      // Tap YTD chip
      await tester.tap(find.byKey(const Key('time_range_YTD')));
      await tester.pumpAndSettle();

      expect(find.text('\$42680'), findsOneWidget);
      expect(find.textContaining('15% under budget'), findsOneWidget);
    });

    testWidgets('Tapping category item highlights category',
        (WidgetTester tester) async {
      configureViewport(tester);
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap Travel category item
      await tester.tap(find.byKey(const Key('category_item_Travel')));
      await tester.pumpAndSettle();

      // Re-tap Travel category item to unhighlight
      await tester.tap(find.byKey(const Key('category_item_Travel')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('category_item_Travel')), findsOneWidget);
    });
  });
}
