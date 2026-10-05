import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Alex Morgan', style: context.headlineMd),
              const SizedBox(height: 4),
              Text('Senior Product Engineer', style: context.metadataText),
              const SizedBox(height: 24),
              Text(
                'Account preferences, policy limits, and security configuration',
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
