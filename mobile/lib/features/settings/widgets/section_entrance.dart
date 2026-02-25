import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SectionEntrance — fade-in + slide-up entrance animation for sections
// ─────────────────────────────────────────────────────────────────────────────

class SectionEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double offsetY;

  const SectionEntrance({
    super.key,
    required this.animation,
    required this.child,
    this.offsetY = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, offsetY / 100),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }
}
