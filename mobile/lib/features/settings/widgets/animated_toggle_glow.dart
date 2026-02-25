import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedToggleGlow — breathing glow effect for active toggle states
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedToggleGlow extends StatefulWidget {
  final bool enabled;
  final Color accentColor;
  final Widget child;

  const AnimatedToggleGlow({
    super.key,
    required this.enabled,
    required this.accentColor,
    required this.child,
  });

  @override
  State<AnimatedToggleGlow> createState() => _AnimatedToggleGlowState();
}

class _AnimatedToggleGlowState extends State<AnimatedToggleGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _breathe = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Breathing glow layer ───────────────────────────────────────
        if (widget.enabled)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _breathe,
                builder: (_, __) {
                  final t = _breathe.value;
                  final opacity = 0.10 + (0.06 * t);
                  final scale = 1.0 + (0.06 * t);

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            widget.accentColor.withValues(alpha: opacity),
                            widget.accentColor.withValues(alpha: opacity * 0.5),
                            widget.accentColor.withValues(alpha: 0),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // ── Child content ──────────────────────────────────────────────
        widget.child,
      ],
    );
  }
}
