import 'package:flutter/material.dart';

/// Micro-interaction widget that provides a subtle tactile scale and fade effect
/// when tapped, reinforcing the Neo-brutalist "Pastel Flat" design language.
class PastelTapScale extends StatefulWidget {
  const PastelTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.96,
    this.fadeDown = 0.92,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOutCubic,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final double fadeDown;
  final Duration duration;
  final Curve curve;
  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<PastelTapScale> createState() => PastelTapScaleState();
}

class PastelTapScaleState extends State<PastelTapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  /// Exposes the animation controller for testing or custom coordination.
  AnimationController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: widget.fadeDown,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (!widget.enabled) return;
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _onPointerUp() {
    if (!widget.enabled) return;
    if (_controller.isAnimating || _controller.value > 0) {
      _controller.reverse();
    }
  }

  void _onPointerCancel() {
    if (!widget.enabled) return;
    if (_controller.isAnimating || _controller.value > 0) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Listener(
      behavior: widget.behavior,
      onPointerDown: (_) => _onPointerDown(),
      onPointerUp: (_) => _onPointerUp(),
      onPointerCancel: (_) => _onPointerCancel(),
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
