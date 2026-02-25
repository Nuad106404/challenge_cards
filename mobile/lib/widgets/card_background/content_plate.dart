import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContentPlate — semi-transparent overlay for card content
// ─────────────────────────────────────────────────────────────────────────────

class ContentPlate extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double opacity;

  const ContentPlate({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.opacity = 0.10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
