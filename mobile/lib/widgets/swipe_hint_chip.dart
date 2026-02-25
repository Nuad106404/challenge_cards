import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SwipeHintVariant — different hint types
// ─────────────────────────────────────────────────────────────────────────────

enum SwipeHintVariant {
  left,   // BACK/SKIP - rose tint
  right,  // NEXT/DONE - mint/green tint
  neutral // MINIGAME - white tint
}

// ─────────────────────────────────────────────────────────────────────────────
// SwipeHintChip — modern glass chip HUD-style hint overlay
// ─────────────────────────────────────────────────────────────────────────────

class SwipeHintChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final SwipeHintVariant variant;
  final double opacity;

  const SwipeHintChip({
    super.key,
    required this.label,
    required this.icon,
    required this.variant,
    this.opacity = 1.0,
  });

  @override
  State<SwipeHintChip> createState() => _SwipeHintChipState();
}

class _SwipeHintChipState extends State<SwipeHintChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
    final isLeft = widget.variant == SwipeHintVariant.left;
    final isRight = widget.variant == SwipeHintVariant.right;
    final isNeutral = widget.variant == SwipeHintVariant.neutral;

    // Color system based on variant
    Color accentColor;
    if (isLeft) {
      accentColor = const Color(0xFFFF6B9D); // soft rose
    } else if (isRight) {
      accentColor = const Color(0xFF38EF7D); // soft mint/green
    } else {
      accentColor = const Color(0xFFFFFFFF); // white
    }

    final baseAlpha = (widget.opacity * 255).round();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _breathe,
        builder: (context, child) {
          final breatheValue = _breathe.value;
          final floatOffset = -4.0 + (breatheValue * 8.0); // -4 to +4 px

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNeutral ? 14 : 16,
            vertical: isNeutral ? 8 : 10,
          ),
          decoration: BoxDecoration(
            // Glass background with subtle gradient tint
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                Color.fromARGB((0.16 * baseAlpha).round(), 255, 255, 255),
                Color.fromARGB((0.10 * baseAlpha).round(), 255, 255, 255),
              ],
            ),
            borderRadius: BorderRadius.circular(999), // capsule
            border: Border.all(
              color: Color.fromARGB((0.14 * baseAlpha).round(), 255, 255, 255),
              width: 1.0,
            ),
            boxShadow: [
              // Soft depth shadow
              BoxShadow(
                color: Color.fromARGB((0.08 * baseAlpha).round(), 0, 0, 0),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
              // Subtle accent glow
              BoxShadow(
                color: Color.fromARGB(
                  (0.12 * baseAlpha).round(),
                  (accentColor.r * 255).round(),
                  (accentColor.g * 255).round(),
                  (accentColor.b * 255).round(),
                ),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner highlight at top edge
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB((0.08 * baseAlpha).round(), 255, 255, 255),
                        Color.fromARGB((0.02 * baseAlpha).round(), 255, 255, 255),
                      ],
                    ),
                  ),
                ),
              ),
              // Content row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLeft)
                    Icon(
                      widget.icon,
                      color: Color.fromARGB((0.85 * baseAlpha).round(), 255, 255, 255),
                      size: isNeutral ? 14 : 16,
                    ),
                  if (isLeft) SizedBox(width: isNeutral ? 6 : 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Color.fromARGB((0.85 * baseAlpha).round(), 255, 255, 255),
                      fontWeight: FontWeight.w600,
                      fontSize: isNeutral ? 11 : 12.5,
                      letterSpacing: 1.4,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB((0.12 * baseAlpha).round(), 0, 0, 0),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  if (isRight) SizedBox(width: isNeutral ? 6 : 8),
                  if (isRight)
                    Icon(
                      widget.icon,
                      color: Color.fromARGB((0.85 * baseAlpha).round(), 255, 255, 255),
                      size: isNeutral ? 14 : 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
