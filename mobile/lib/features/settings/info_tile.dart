import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InfoTile — stat card for app info display
// ─────────────────────────────────────────────────────────────────────────────

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x12000000),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C3483),
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D1B4E),
                letterSpacing: -0.1,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Value badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0x206C3483),
                width: 1.0,
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C3483),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
