import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, this.transactionId});

  final String? transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Starbucks - \$6.75', style: context.headlineLg),
              const SizedBox(height: 8),
              Text(
                'Transaction ID: ${transactionId ?? "TXN-89412"}',
                style: context.metadataText,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
