import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/features/insights/providers/insights_provider.dart';

/// Screen displaying Spend Insights with fl_chart donut/bar charts,
/// time range filters (1W, 1M, 3M, YTD), and category expense breakdowns.
/// Based on Stitch Screen ID: 787cc57e905649faa7585b47ab6da9a0 ("Spend Insights").
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;
    final state = ref.watch(insightsProvider);
    final notifier = ref.read(insightsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spend Insights'),
        actions: [
          IconButton(
            key: const Key('toggle_chart_type_button'),
            tooltip: state.isDonutChart ? 'View Bar Chart' : 'View Donut Chart',
            icon: Icon(
              state.isDonutChart
                  ? Icons.bar_chart_rounded
                  : Icons.pie_chart_rounded,
              color: colors.borderDark,
            ),
            onPressed: notifier.toggleChartType,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.marginMobile,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Budget Encouragement Banner
              _buildEncouragementBanner(context, colors, state),
              const SizedBox(height: 16),

              // 2. Time-Range Filter Chips (1W, 1M, 3M, YTD)
              _buildTimeRangeChips(context, colors, state, notifier),
              const SizedBox(height: 20),

              // 3. Primary Chart Card (Donut Chart or Bar Chart)
              _buildPrimaryChartCard(context, colors, state, notifier),
              const SizedBox(height: 20),

              // 4. Trend Overview Card
              _buildTrendCard(context, colors, state),
              const SizedBox(height: 20),

              // 5. Category Breakdown Detailed List
              _buildCategoryBreakdownList(context, colors, state, notifier),
              const SizedBox(height: 20),

              // 6. AI Insights Bento Cards
              _buildAiInsightsBento(context, colors),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Encouragement Banner: "You're 12% under budget this month. Keep it up! 👏"
  Widget _buildEncouragementBanner(
    BuildContext context,
    AppPastelColors colors,
    InsightsState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.mint.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.primarySage.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.05),
            offset: const Offset(2, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.mint,
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderDark, width: 1.0),
            ),
            child: Icon(
              Icons.trending_down_rounded,
              color: colors.primarySage,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: context.bodyMedium.copyWith(
                  color: colors.borderDark,
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: "You're "),
                  TextSpan(
                    text: '${state.percentUnderBudget}% under budget ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: 'for ${state.timeRange.fullLabel.toLowerCase()}. Keep it up! 👏',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Time-Range Filter Chips: 1W, 1M, 3M, YTD
  Widget _buildTimeRangeChips(
    BuildContext context,
    AppPastelColors colors,
    InsightsState state,
    InsightsNotifier notifier,
  ) {
    return Row(
      children: TimeRange.values.map((range) {
        final isSelected = state.timeRange == range;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: range != TimeRange.values.last ? 8.0 : 0.0,
            ),
            child: InkWell(
              key: Key('time_range_${range.label}'),
              onTap: () => notifier.setTimeRange(range),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primarySage : colors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.borderDark,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.borderDark.withValues(alpha: 0.15),
                            offset: const Offset(1.5, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    range.label,
                    style: context.labelMd.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : colors.borderDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 3. Primary Chart Card: Spend by Category (fl_chart Pie/Donut or Bar)
  Widget _buildPrimaryChartCard(
    BuildContext context,
    AppPastelColors colors,
    InsightsState state,
    InsightsNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spend by Category',
                style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.cardSurfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.borderDark, width: 1.0),
                ),
                child: Text(
                  state.timeRange.label,
                  style: context.metadataText.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.borderDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Display
          SizedBox(
            height: 210,
            child: state.isDonutChart
                ? _buildDonutChart(colors, state, notifier)
                : _buildCategoryBarChart(colors, state, notifier),
          ),
          const SizedBox(height: 16),

          // Category Legend Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.categories.map((c) {
              final isSelected = state.selectedCategory == c.category;
              return InkWell(
                onTap: () => notifier.selectCategory(c.category),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? c.color.withValues(alpha: 0.2)
                        : colors.cardSurfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? c.color : colors.borderDark.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: c.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.category,
                        style: context.metadataText.copyWith(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: colors.borderDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${c.percentage.toStringAsFixed(0)}%',
                        style: context.metadataText.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.borderDark.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Donut Chart using fl_chart PieChart
  Widget _buildDonutChart(
    AppPastelColors colors,
    InsightsState state,
    InsightsNotifier notifier,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedPieIndex = -1;
                    return;
                  }
                  _touchedPieIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                  if (_touchedPieIndex >= 0 &&
                      _touchedPieIndex < state.categories.length) {
                    notifier.selectCategory(
                      state.categories[_touchedPieIndex].category,
                    );
                  }
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 3,
            centerSpaceRadius: 54,
            sections: List.generate(state.categories.length, (i) {
              final cat = state.categories[i];
              final isTouched = i == _touchedPieIndex ||
                  state.selectedCategory == cat.category;
              final radius = isTouched ? 36.0 : 28.0;

              return PieChartSectionData(
                color: cat.color,
                value: cat.amount,
                title: isTouched ? '${cat.percentage.toStringAsFixed(0)}%' : '',
                radius: radius,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ),

        // Center Total Spent Text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TOTAL',
              style: context.metadataText.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: colors.borderDark.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${state.totalSpent.toStringAsFixed(0)}',
              key: const Key('insights_total_spent_text'),
              style: context.headlineLg.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.borderDark,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Alternative Category Bar Chart using fl_chart BarChart
  Widget _buildCategoryBarChart(
    AppPastelColors colors,
    InsightsState state,
    InsightsNotifier notifier,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: state.categories.map((c) => c.amount).reduce((a, b) => a > b ? a : b) * 1.25,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cat = state.categories[groupIndex];
              return BarTooltipItem(
                '${cat.category}\n\$${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= state.categories.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.categories[idx].category,
                    style: context.metadataText.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(state.categories.length, (i) {
          final cat = state.categories[i];
          final isSelected = state.selectedCategory == cat.category;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: cat.amount,
                color: isSelected ? colors.primarySage : cat.color,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                borderSide: BorderSide(
                  color: colors.borderDark,
                  width: 1.0,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// 4. Trend Overview Card (fl_chart BarChart for weekly/monthly trend)
  Widget _buildTrendCard(
    BuildContext context,
    AppPastelColors colors,
    InsightsState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trend',
                style: context.headlineMd.copyWith(fontWeight: FontWeight.w700),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: colors.primarySage,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: state.trendPoints.map((p) => p.amount).reduce((a, b) => a > b ? a : b) * 1.25,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final point = state.trendPoints[groupIndex];
                      return BarTooltipItem(
                        '${point.label}: \$${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= state.trendPoints.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.trendPoints[idx].label,
                            style: context.metadataText.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: colors.borderDark.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(state.trendPoints.length, (i) {
                  final point = state.trendPoints[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: point.amount,
                        color: colors.mint,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                        borderSide: BorderSide(
                          color: colors.borderDark,
                          width: 1.0,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Category Breakdown Detailed List with Progress Meters
  Widget _buildCategoryBreakdownList(
    BuildContext context,
    AppPastelColors colors,
    InsightsState state,
    InsightsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY BREAKDOWN',
          style: context.metadataText.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: colors.borderDark.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),

        ...state.categories.map((c) {
          final isSelected = state.selectedCategory == c.category;

          return InkWell(
            key: Key('category_item_${c.category}'),
            onTap: () => notifier.selectCategory(c.category),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.mint.withValues(alpha: 0.25)
                    : colors.cardSurface,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: isSelected ? colors.primarySage : colors.borderDark,
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.borderDark.withValues(alpha: 0.04),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Name + Amount
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.borderDark, width: 1.0),
                        ),
                        child: Icon(c.icon, size: 18, color: c.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.category,
                              style: context.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${c.percentage.toStringAsFixed(1)}% of total budget',
                              style: context.metadataText.copyWith(
                                color: colors.borderDark.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${c.amount.toStringAsFixed(2)}',
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.borderDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.percentage / 100.0,
                      minHeight: 8,
                      backgroundColor: colors.cardSurfaceAlt,
                      valueColor: AlwaysStoppedAnimation<Color>(c.color),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 6. AI Insights Bento Cards
  Widget _buildAiInsightsBento(
    BuildContext context,
    AppPastelColors colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.lavender.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: colors.borderDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.borderDark.withValues(alpha: 0.08),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: colors.secondaryPlum, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Spend Analysis',
                style: context.labelMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Travel accounts for 65% of your outflow this cycle. Booking flights 14+ days in advance is projected to reduce overall travel expenditure by ~12%.',
            style: context.bodyMedium.copyWith(
              color: colors.borderDark.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
