import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_guard/core/theme/app_theme.dart';
import 'package:expense_guard/core/router/app_router.dart';
import 'package:expense_guard/core/errors/app_error_handler.dart';
import 'package:expense_guard/core/errors/app_error_boundary.dart';
import 'package:expense_guard/features/shared/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// The root application widget for ExpenseGuard.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ExpenseGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      scaffoldMessengerKey: AppErrorHandler.scaffoldMessengerKey,
      builder: (context, child) {
        return AppErrorBoundary(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Compatibility alias for MyApp.
typedef ExpenseGuardApp = MyApp;
