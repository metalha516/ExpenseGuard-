import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class PolicyCheckScreen extends StatelessWidget {
  const PolicyCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Policy Check')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_outlined, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text('Policy Compliance Verified', style: context.headlineMd),
              const SizedBox(height: 8),
              Text(
                'Expense falls within daily meal budget limit (\$50.00)',
                style: context.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Submit to Approvals'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
