import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SettingsSection — reusable section container with title
// ─────────────────────────────────────────────────────────────────────────────

class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D1B4E),
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2D1B4E).withValues(alpha: 0.5),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }
}
