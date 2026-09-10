import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Time range filters for spend analytics.
enum TimeRange {
  oneWeek('1W', 'Last 7 Days'),
  oneMonth('1M', 'This Month'),
  threeMonths('3M', 'Last 3 Months'),
  yearToDate('YTD', 'Year to Date');

  const TimeRange(this.label, this.fullLabel);
  final String label;
  final String fullLabel;
}

/// Represents spending breakdown for a specific category.
@immutable
class CategorySpend {
  const CategorySpend({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  final String category;
  final double amount;
  final double percentage; // e.g. 65.0 for 65%
  final Color color;
  final IconData icon;

  CategorySpend copyWith({
    String? category,
    double? amount,
    double? percentage,
    Color? color,
    IconData? icon,
  }) {
    return CategorySpend(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

/// Represents trend bar data point (e.g. for BarChart).
@immutable
class TrendDataPoint {
  const TrendDataPoint({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}

/// Immutable state for the Spend Insights screen.
@immutable
class InsightsState {
  const InsightsState({
    required this.timeRange,
    required this.categories,
    required this.trendPoints,
    required this.totalSpent,
    required this.budgetLimit,
    required this.percentUnderBudget,
    this.selectedCategory,
    this.isDonutChart = true,
  });

  final TimeRange timeRange;
  final List<CategorySpend> categories;
  final List<TrendDataPoint> trendPoints;
  final double totalSpent;
  final double budgetLimit;
  final int percentUnderBudget;
  final String? selectedCategory;
  final bool isDonutChart;

  InsightsState copyWith({
    TimeRange? timeRange,
    List<CategorySpend>? categories,
    List<TrendDataPoint>? trendPoints,
    double? totalSpent,
    double? budgetLimit,
    int? percentUnderBudget,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    bool? isDonutChart,
  }) {
    return InsightsState(
      timeRange: timeRange ?? this.timeRange,
      categories: categories ?? this.categories,
      trendPoints: trendPoints ?? this.trendPoints,
      totalSpent: totalSpent ?? this.totalSpent,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      percentUnderBudget: percentUnderBudget ?? this.percentUnderBudget,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      isDonutChart: isDonutChart ?? this.isDonutChart,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightsState &&
          runtimeType == other.runtimeType &&
          timeRange == other.timeRange &&
          totalSpent == other.totalSpent &&
          budgetLimit == other.budgetLimit &&
          percentUnderBudget == other.percentUnderBudget &&
          selectedCategory == other.selectedCategory &&
          isDonutChart == other.isDonutChart;

  @override
  int get hashCode => Object.hash(
        timeRange,
        totalSpent,
        budgetLimit,
        percentUnderBudget,
        selectedCategory,
        isDonutChart,
      );
}

/// Riverpod Notifier managing Spend Insights filters, charts, and data aggregations.
class InsightsNotifier extends Notifier<InsightsState> {
  @override
  InsightsState build() {
    return _buildStateForRange(TimeRange.oneMonth);
  }

  /// Change active time-range filter (1W, 1M, 3M, YTD).
  void setTimeRange(TimeRange range) {
    state = _buildStateForRange(range);
  }

  /// Select or deselect a category in the charts.
  void selectCategory(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Toggle between Donut Chart and Bar Chart.
  void toggleChartType() {
    state = state.copyWith(isDonutChart: !state.isDonutChart);
  }

  static InsightsState _buildStateForRange(TimeRange range) {
    switch (range) {
      case TimeRange.oneWeek:
        return const InsightsState(
          timeRange: TimeRange.oneWeek,
          totalSpent: 860.00,
          budgetLimit: 1250.00,
          percentUnderBudget: 31,
          categories: [
            CategorySpend(
              category: 'Travel',
              amount: 450.00,
              percentage: 52.3,
              color: Color(0xFF0F5E4C), // Deep Sage
              icon: Icons.flight_takeoff_rounded,
            ),
            CategorySpend(
              category: 'Meals',
              amount: 280.00,
              percentage: 32.6,
              color: Color(0xFF755B00), // Muted Amber
              icon: Icons.restaurant_rounded,
            ),
            CategorySpend(
              category: 'Software',
              amount: 130.00,
              percentage: 15.1,
              color: Color(0xFFFED255), // Pastel Gold
              icon: Icons.devices_rounded,
            ),
          ],
          trendPoints: [
            TrendDataPoint(label: 'Mon', amount: 120),
            TrendDataPoint(label: 'Tue', amount: 240),
            TrendDataPoint(label: 'Wed', amount: 80),
            TrendDataPoint(label: 'Thu', amount: 190),
            TrendDataPoint(label: 'Fri', amount: 150),
            TrendDataPoint(label: 'Sat', amount: 50),
            TrendDataPoint(label: 'Sun', amount: 30),
          ],
        );

      case TimeRange.oneMonth:
        // Stitch reference: Travel $3,450 (65%), Meals $1,200 (23%), Software $450 (8%), Supplies $210 (4%)
        return const InsightsState(
          timeRange: TimeRange.oneMonth,
          totalSpent: 5310.00,
          budgetLimit: 6000.00,
          percentUnderBudget: 12,
          categories: [
            CategorySpend(
              category: 'Travel',
              amount: 3450.00,
              percentage: 65.0,
              color: Color(0xFF0F5E4C), // Deep Sage
              icon: Icons.flight_takeoff_rounded,
            ),
            CategorySpend(
              category: 'Meals',
              amount: 1200.00,
              percentage: 23.0,
              color: Color(0xFF755B00), // Muted Amber
              icon: Icons.restaurant_rounded,
            ),
            CategorySpend(
              category: 'Software',
              amount: 450.00,
              percentage: 8.0,
              color: Color(0xFFFED255), // Pastel Gold
              icon: Icons.devices_rounded,
            ),
            CategorySpend(
              category: 'Supplies',
              amount: 210.00,
              percentage: 4.0,
              color: Color(0xFFE2CCF0), // Lavender
              icon: Icons.inventory_2_rounded,
            ),
          ],
          trendPoints: [
            TrendDataPoint(label: 'W1', amount: 1100),
            TrendDataPoint(label: 'W2', amount: 1850),
            TrendDataPoint(label: 'W3', amount: 1420),
            TrendDataPoint(label: 'W4', amount: 940),
          ],
        );

      case TimeRange.threeMonths:
        return const InsightsState(
          timeRange: TimeRange.threeMonths,
          totalSpent: 14820.00,
          budgetLimit: 18000.00,
          percentUnderBudget: 18,
          categories: [
            CategorySpend(
              category: 'Travel',
              amount: 9850.00,
              percentage: 66.5,
              color: Color(0xFF0F5E4C),
              icon: Icons.flight_takeoff_rounded,
            ),
            CategorySpend(
              category: 'Meals',
              amount: 3120.00,
              percentage: 21.0,
              color: Color(0xFF755B00),
              icon: Icons.restaurant_rounded,
            ),
            CategorySpend(
              category: 'Software',
              amount: 1350.00,
              percentage: 9.1,
              color: Color(0xFFFED255),
              icon: Icons.devices_rounded,
            ),
            CategorySpend(
              category: 'Supplies',
              amount: 500.00,
              percentage: 3.4,
              color: Color(0xFFE2CCF0),
              icon: Icons.inventory_2_rounded,
            ),
          ],
          trendPoints: [
            TrendDataPoint(label: 'Sep', amount: 4620),
            TrendDataPoint(label: 'Oct', amount: 4890),
            TrendDataPoint(label: 'Nov', amount: 5310),
          ],
        );

      case TimeRange.yearToDate:
        return const InsightsState(
          timeRange: TimeRange.yearToDate,
          totalSpent: 42680.00,
          budgetLimit: 50000.00,
          percentUnderBudget: 15,
          categories: [
            CategorySpend(
              category: 'Travel',
              amount: 27500.00,
              percentage: 64.4,
              color: Color(0xFF0F5E4C),
              icon: Icons.flight_takeoff_rounded,
            ),
            CategorySpend(
              category: 'Meals',
              amount: 9400.00,
              percentage: 22.0,
              color: Color(0xFF755B00),
              icon: Icons.restaurant_rounded,
            ),
            CategorySpend(
              category: 'Software',
              amount: 4180.00,
              percentage: 9.8,
              color: Color(0xFFFED255),
              icon: Icons.devices_rounded,
            ),
            CategorySpend(
              category: 'Supplies',
              amount: 1600.00,
              percentage: 3.8,
              color: Color(0xFFE2CCF0),
              icon: Icons.inventory_2_rounded,
            ),
          ],
          trendPoints: [
            TrendDataPoint(label: 'Q1', amount: 11200),
            TrendDataPoint(label: 'Q2', amount: 13800),
            TrendDataPoint(label: 'Q3', amount: 12100),
            TrendDataPoint(label: 'Q4', amount: 5580),
          ],
        );
    }
  }
}

/// Global Riverpod provider for Spend Insights.
final insightsProvider =
    NotifierProvider<InsightsNotifier, InsightsState>(InsightsNotifier.new);
