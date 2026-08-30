import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class NotificationsCenterScreen extends StatelessWidget {
  const NotificationsCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Notifications Center', style: context.headlineMd),
              const SizedBox(height: 8),
              Text(
                'Policy alerts, approval requests, and receipt processing updates',
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
