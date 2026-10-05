import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/features/insights/providers/insights_provider.dart';

void main() {
  group('InsightsProvider Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state loads 1M metrics matching Stitch specification', () {
      final state = container.read(insightsProvider);

      expect(state.timeRange, TimeRange.oneMonth);
      expect(state.totalSpent, 5310.00);
      expect(state.budgetLimit, 6000.00);
      expect(state.percentUnderBudget, 12);
      expect(state.isDonutChart, isTrue);

      // Verify category breakdown
      expect(state.categories.length, 4);
      final travel = state.categories.firstWhere((c) => c.category == 'Travel');
      expect(travel.amount, 3450.00);
      expect(travel.percentage, 65.0);

      final meals = state.categories.firstWhere((c) => c.category == 'Meals');
      expect(meals.amount, 1200.00);
      expect(meals.percentage, 23.0);

      final software = state.categories.firstWhere((c) => c.category == 'Software');
      expect(software.amount, 450.00);
      expect(software.percentage, 8.0);
    });

    test('setTimeRange(1W) updates metrics and trend points for 7 days', () {
      final notifier = container.read(insightsProvider.notifier);

      notifier.setTimeRange(TimeRange.oneWeek);

      final state = container.read(insightsProvider);
      expect(state.timeRange, TimeRange.oneWeek);
      expect(state.totalSpent, 860.00);
      expect(state.percentUnderBudget, 31);
      expect(state.trendPoints.length, 7); // Mon - Sun
    });

    test('setTimeRange(3M) and setTimeRange(YTD) update aggregations', () {
      final notifier = container.read(insightsProvider.notifier);

      notifier.setTimeRange(TimeRange.threeMonths);
      var state = container.read(insightsProvider);
      expect(state.timeRange, TimeRange.threeMonths);
      expect(state.totalSpent, 14820.00);
      expect(state.trendPoints.length, 3); // Sep, Oct, Nov

      notifier.setTimeRange(TimeRange.yearToDate);
      state = container.read(insightsProvider);
      expect(state.timeRange, TimeRange.yearToDate);
      expect(state.totalSpent, 42680.00);
      expect(state.trendPoints.length, 4); // Q1 - Q4
    });

    test('selectCategory toggles active category filter', () {
      final notifier = container.read(insightsProvider.notifier);

      notifier.selectCategory('Travel');
      var state = container.read(insightsProvider);
      expect(state.selectedCategory, 'Travel');

      // Tapping same category deselects
      notifier.selectCategory('Travel');
      state = container.read(insightsProvider);
      expect(state.selectedCategory, isNull);
    });

    test('toggleChartType toggles between Donut and Bar chart', () {
      final notifier = container.read(insightsProvider.notifier);

      expect(container.read(insightsProvider).isDonutChart, isTrue);

      notifier.toggleChartType();
      expect(container.read(insightsProvider).isDonutChart, isFalse);

      notifier.toggleChartType();
      expect(container.read(insightsProvider).isDonutChart, isTrue);
    });
  });
}
