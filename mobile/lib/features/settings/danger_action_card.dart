import 'package:flutter/material.dart';
import '../../../core/utils/haptic_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DangerActionCard — red-tinted destructive action card with confirmation
// ─────────────────────────────────────────────────────────────────────────────

class DangerActionCard extends StatefulWidget {
  final String title;
  final String caption;
  final IconData icon;
  final VoidCallback onConfirm;

  const DangerActionCard({
    super.key,
    required this.title,
    required this.caption,
    required this.icon,
    required this.onConfirm,
  });

  @override
  State<DangerActionCard> createState() => _DangerActionCardState();
}

class _DangerActionCardState extends State<DangerActionCard> {
  bool _pressing = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressing = true);
  void _onTapUp(TapUpDetails _) {
    setState(() => _pressing = false);
    HapticHelper.medium();
    _showConfirmDialog();
  }
  void _onTapCancel() => setState(() => _pressing = false);

  Future<void> _showConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: Text('${widget.caption}\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              HapticHelper.selection();
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticHelper.heavy();
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE8436A),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressing ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD6DD),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08E8436A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFFE8436A),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D1B4E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.caption,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF2D1B4E).withValues(alpha: 0.55),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Arrow indicator
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFE8436A),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
