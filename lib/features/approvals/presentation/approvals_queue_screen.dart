import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class ApprovalsQueueScreen extends StatelessWidget {
  const ApprovalsQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals Queue')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rule_folder_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Pending Approvals (3)', style: context.headlineMd),
              const SizedBox(height: 8),
              Text(
                'Review pending team expense submissions and policy flags',
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
