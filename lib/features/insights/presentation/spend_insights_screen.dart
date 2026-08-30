import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class SpendInsightsScreen extends StatelessWidget {
  const SpendInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spend Insights')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.donut_large_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Monthly Analytics', style: context.headlineMd),
              const SizedBox(height: 8),
              Text(
                'AI categorization and spending trend visualization',
                style: context.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
