import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CardType — different card types in the game
// ─────────────────────────────────────────────────────────────────────────────

enum CardType {
  question,
  dare,
  vote,
  punishment,
  bonus,
}

// ─────────────────────────────────────────────────────────────────────────────
// CardThemeData — theme configuration for each card type
// ─────────────────────────────────────────────────────────────────────────────

class CardThemeData {
  final LinearGradient baseGradient;
  final Color glowColor;
  final Color patternColor;
  final bool preferLightText;

  const CardThemeData({
    required this.baseGradient,
    required this.glowColor,
    required this.patternColor,
    required this.preferLightText,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme definitions for each card type
// ─────────────────────────────────────────────────────────────────────────────

CardThemeData themeFor(CardType type) {
  switch (type) {
    case CardType.question:
      return const CardThemeData(
        baseGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C6FDC), // cool lavender
            Color(0xFF5B4FC4), // indigo
            Color(0xFF4A3FB5), // deep indigo
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        glowColor: Color(0xFF9D8FFF),
        patternColor: Color(0x0AFFFFFF),
        preferLightText: true,
      );

    case CardType.dare:
      return const CardThemeData(
        baseGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8436A), // energetic pink
            Color(0xFFD62E5A), // magenta
            Color(0xFFC41F4A), // deep magenta
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        glowColor: Color(0xFFFF5A7F),
        patternColor: Color(0x0DFFFFFF),
        preferLightText: true,
      );

    case CardType.vote:
      return const CardThemeData(
        baseGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF11998E), // teal
            Color(0xFF0D7A6F), // mint
            Color(0xFF095B52), // deep teal
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        glowColor: Color(0xFF38D9C8),
        patternColor: Color(0x0BFFFFFF),
        preferLightText: true,
      );

    case CardType.punishment:
      return const CardThemeData(
        baseGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF8C42), // warm orange
            Color(0xFFE8672A), // red-orange
            Color(0xFFD14D1A), // deep red
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        glowColor: Color(0xFFFFA55F),
        patternColor: Color(0x0CFFFFFF),
        preferLightText: true,
      );

    case CardType.bonus:
      return const CardThemeData(
        baseGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // gold
            Color(0xFFFFC107), // amber
            Color(0xFFFF9800), // deep amber
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        glowColor: Color(0xFFFFE54C),
        patternColor: Color(0x0F000000),
        preferLightText: false,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper to get foreground text color
// ─────────────────────────────────────────────────────────────────────────────

Color foregroundColorFor(CardType type) {
  final theme = themeFor(type);
  return theme.preferLightText
      ? const Color(0xFFFAFAFA)
      : const Color(0xFF1A1A1A);
}
