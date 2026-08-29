import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class CorporateCardsScreen extends StatelessWidget {
  const CorporateCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Corporate Cards')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 280,
                height: 170,
                decoration: BoxDecoration(
                  color: colors.lavender,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.borderDark,
                    width: AppTheme.borderWidth,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ExpenseGuard Virtual', style: context.labelMd),
                    Text('•••• •••• •••• 4291', style: context.headlineMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Alex Morgan', style: context.labelMd),
                        Text('12/28', style: context.metadataText),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Card Controls & Limits', style: context.headlineMd),
              const SizedBox(height: 8),
              Text('Monthly Limit: \$5,000.00', style: context.bodyMd),
            ],
          ),
        ),
      ),
    );
  }
}
