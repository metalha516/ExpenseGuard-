import 'package:flutter/material.dart';
import 'package:expense_guard/core/theme/app_theme.dart';

/// Error boundary widget catching Flutter build errors with a Pastel Flat recovery UI.
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.onRetry,
  });

  final Widget child;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final VoidCallback? onRetry;

  /// Programmatically reports an error to the nearest ancestor AppErrorBoundary.
  static void reportError(
    BuildContext context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    final state = context.findAncestorStateOfType<_AppErrorBoundaryState>();
    state?.catchError(error, stackTrace);
  }

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;

  void catchError(Object error, [StackTrace? stackTrace]) {
    widget.onError?.call(error, stackTrace);
    setState(() {
      _error = error;
    });
  }

  void _resetError() {
    setState(() {
      _error = null;
    });
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      final colors = context.pastelColors;

      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.marginMobile * 1.5),
            child: Container(
              key: const Key('app_error_boundary_card'),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.cardSurface,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: colors.borderDark, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: colors.borderDark.withValues(alpha: 0.1),
                    offset: const Offset(4, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.peach,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.borderDark, width: 1.5),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: colors.borderDark,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Something went wrong',
                    style: context.headlineMd.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We encountered an unexpected error while loading this screen. Please try again.',
                    style: context.bodyMedium.copyWith(
                      color: colors.borderDark.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    key: const Key('error_boundary_retry_button'),
                    onPressed: _resetError,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primarySage,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: colors.borderDark, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
