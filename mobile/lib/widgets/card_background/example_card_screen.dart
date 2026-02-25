import 'package:flutter/material.dart';
import 'card_background.dart';
import 'card_theme.dart';
import 'content_plate.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExampleCardScreen — demonstrates CardBackground usage
// ─────────────────────────────────────────────────────────────────────────────

class ExampleCardScreen extends StatelessWidget {
  final CardType cardType;
  final String title;
  final String content;

  const ExampleCardScreen({
    super.key,
    required this.cardType,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = foregroundColorFor(cardType);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CardBackground(
              type: cardType,
              borderRadius: BorderRadius.circular(32),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Card type label ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cardType.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor.withValues(alpha: 0.85),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Main content with ContentPlate ─────────────────
                    ContentPlate(
                      borderRadius: BorderRadius.circular(24),
                      opacity: 0.10,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          children: [
                            // Title
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Content
                            Text(
                              content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: textColor.withValues(alpha: 0.85),
                                height: 1.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Action button ──────────────────────────────────
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Example usage in different card types
// ─────────────────────────────────────────────────────────────────────────────

class CardExamplesDemo extends StatelessWidget {
  const CardExamplesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        ExampleCardScreen(
          cardType: CardType.question,
          title: 'What would you do?',
          content: 'If you could have any superpower for one day, what would it be and why?',
        ),
        ExampleCardScreen(
          cardType: CardType.dare,
          title: 'Dare Challenge',
          content: 'Do your best impression of a celebrity for 30 seconds!',
        ),
        ExampleCardScreen(
          cardType: CardType.vote,
          title: 'Group Vote',
          content: 'Who is most likely to become famous?',
        ),
        ExampleCardScreen(
          cardType: CardType.punishment,
          title: 'Punishment',
          content: 'Do 10 push-ups right now!',
        ),
        ExampleCardScreen(
          cardType: CardType.bonus,
          title: 'Bonus Round!',
          content: 'Everyone gets a free pass on their next challenge!',
        ),
      ],
    );
  }
}
