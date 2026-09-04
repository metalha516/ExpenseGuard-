import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

/// Screen for reviewing extracted receipt data, merchant, category, and amounts.
class ExpenseReviewScreen extends StatelessWidget {
  const ExpenseReviewScreen({
    super.key,
    this.imagePath,
  });

  /// The captured receipt file path passed from the Camera flow.
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final colors = context.pastelColors;

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
              const SizedBox(height: 16),

              // Captured Image Path Indicator
              if (imagePath != null && imagePath!.isNotEmpty)
                Container(
                  key: const Key('reviewed_receipt_image_badge'),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.mintDim,
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                    border: Border.all(
                      color: colors.borderDark,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: colors.borderDark),
                      const SizedBox(width: 6),
                      Text(
                        'Captured: ${imagePath!.split('/').last.split(r'\').last}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.borderDark,
                        ),
                      ),
                    ],
                  ),
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
