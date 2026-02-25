import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AmbientGlowLayer — breathing glow behind selected mode tile
// ─────────────────────────────────────────────────────────────────────────────

class AmbientGlowLayer extends StatefulWidget {
  final Rect? targetRect;
  final Color accentColor;
  final bool visible;

  const AmbientGlowLayer({
    super.key,
    required this.targetRect,
    required this.accentColor,
    required this.visible,
  });

  @override
  State<AmbientGlowLayer> createState() => _AmbientGlowLayerState();
}

class _AmbientGlowLayerState extends State<AmbientGlowLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late Animation<double> _breathe;

  // Cached per-accent-color values — only recomputed when color changes.
  late Color _accent;

  @override
  void initState() {
    super.initState();
    _accent = widget.accentColor;
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _breathe = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AmbientGlowLayer old) {
    super.didUpdateWidget(old);
    if (old.accentColor != widget.accentColor) {
      _accent = widget.accentColor;
    }
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || widget.targetRect == null) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: widget.targetRect!.left - 20,
      top: widget.targetRect!.top - 20,
      width: widget.targetRect!.width + 40,
      height: widget.targetRect!.height + 40,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _breathe,
            builder: (_, __) {
              final t = _breathe.value;
              final opacity = 0.10 + (0.08 * t);
              final scale = 1.0 + (0.08 * t);
              final driftX = sin(t * 2 * pi) * 4;
              final driftY = sin(t * 2 * pi * 0.7 + 1.2) * 3;

              return Transform.translate(
                offset: Offset(driftX, driftY),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      // Use cached _accent so withValues() is not called
                      // with the full widget.accentColor lookup every frame.
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          _accent.withValues(alpha: opacity),
                          _accent.withValues(alpha: opacity * 0.6),
                          _accent.withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
