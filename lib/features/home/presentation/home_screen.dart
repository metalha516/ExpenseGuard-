import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExpenseGuard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => context.push('/insights'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, Alex', style: context.headlineLg),
            const SizedBox(height: AppTheme.stackGap),

            // Large Spend Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total spend this month', style: context.bodyMd),
                    const SizedBox(height: 6),
                    Text('\$2,450.80', style: context.displayCurrency),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Approved: \$1,850', style: context.labelMd),
                            const SizedBox(width: 12),
                            Text('Pending: \$600.80', style: context.labelMd),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.mint,
                            foregroundColor: colors.borderDark,
                            minimumSize: const Size(100, 36),
                          ),
                          onPressed: () => context.push('/submit-expense'),
                          child: const Text('+ Expense'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.stackGap),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/submit-expense'),
                    child: const Text('Scan Receipt'),
                  ),
                ),
                const SizedBox(width: AppTheme.gutterMobile),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/cards'),
                    child: const Text('Cards'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.stackGap),

            // Recent Transactions header
            Text('Recent Transactions', style: context.headlineMd),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.mint,
                  child: Icon(Icons.local_cafe, color: colors.borderDark),
                ),
                title: Text('Starbucks', style: context.bodyLarge),
                subtitle: Text('Meals & Dining • Today', style: context.metadataText),
                trailing: Text('-\$6.75', style: context.bodyLarge),
                onTap: () => context.push('/transaction-detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
