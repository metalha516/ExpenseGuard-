import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class ExpenseReviewScreen extends StatelessWidget {
  const ExpenseReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Review')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Review & Edit Details', style: context.headlineMd),
              const SizedBox(height: 12),
              Text(
                'Verify merchant, category, and amounts before submission',
                style: context.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/policy-check'),
                child: const Text('Run Policy Check'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
