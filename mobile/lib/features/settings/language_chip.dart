import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LanguageChip — pill-style selectable language chip with animation
// ─────────────────────────────────────────────────────────────────────────────

class LanguageChip extends StatefulWidget {
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const LanguageChip({
    super.key,
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  State<LanguageChip> createState() => _LanguageChipState();
}

class _LanguageChipState extends State<LanguageChip> {
  bool _pressing = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressing = true);
  void _onTapUp(TapUpDetails _) {
    setState(() => _pressing = false);
    widget.onTap();
  }
  void _onTapCancel() => setState(() => _pressing = false);

  @override
  Widget build(BuildContext context) {
    final scale = _pressing ? 0.96 : (widget.selected ? 1.05 : 1.0);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: widget.selected ? 200 : 120),
        curve: widget.selected ? Curves.easeOutBack : Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? const Color(0xFF4A90E2)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF4A90E2)
                  : const Color(0x20000000),
              width: widget.selected ? 1.5 : 1.0,
            ),
            boxShadow: widget.selected
                ? [
                    const BoxShadow(
                      color: Color(0x304A90E2),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.selected
                      ? Colors.white
                      : const Color(0xFF2D1B4E),
                  letterSpacing: 0.2,
                ),
                child: Text(widget.label),
              ),
              if (widget.selected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
