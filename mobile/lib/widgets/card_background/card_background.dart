import 'package:flutter/material.dart';
import 'card_theme.dart';
import 'card_pattern_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CardBackground — premium card background with gradient, patterns, and depth
// ─────────────────────────────────────────────────────────────────────────────

class CardBackground extends StatelessWidget {
  final CardType type;
  final Widget child;
  final BorderRadius borderRadius;

  const CardBackground({
    super.key,
    required this.type,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeFor(type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // 3-layer depth shadow system
        boxShadow: const [
          // Layer 1 — deep soft shadow
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 40,
            offset: Offset(0, 12),
            spreadRadius: -4,
          ),
          // Layer 2 — mid shadow
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          // Layer 3 — contact shadow
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // ── Base gradient ──────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: theme.baseGradient,
                ),
              ),
            ),

            // ── Subtle pattern layer ───────────────────────────────────
            Positioned.fill(
              child: CustomPaint(
                painter: CardPatternPainter(
                  type: type,
                  patternColor: theme.patternColor,
                ),
              ),
            ),

            // ── Edge vignette (darken corners) ─────────────────────────
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color(0x00000000),
                      Color(0x18000000),
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ── Top-edge laminated reflection ──────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x18FFFFFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),

            // ── Inner border highlight ─────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: const Color(0x1AFFFFFF),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            // ── Subtle glow bloom (top-left) ───────────────────────────
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.glowColor.withValues(alpha: 0.12),
                      theme.glowColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Child content ──────────────────────────────────────────
            Positioned.fill(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
