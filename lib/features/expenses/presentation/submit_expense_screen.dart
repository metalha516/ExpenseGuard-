import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class SubmitExpenseScreen extends StatelessWidget {
  const SubmitExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Expense')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Capture Receipt', style: context.headlineMd),
              const SizedBox(height: 8),
              Text(
                'Point camera at receipt for AI line-item extraction',
                style: context.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/expense-review'),
                child: const Text('Review Scanned Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
