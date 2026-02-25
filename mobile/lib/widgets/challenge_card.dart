import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../features/game/game_provider.dart';

class ChallengeCard extends StatelessWidget {
  final CardModel card;
  final String playerName;

  const ChallengeCard({
    super.key,
    required this.card,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<GameProvider>().locale;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              playerName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _TypeBadge(type: card.type),
            const SizedBox(height: 32),
            Text(
              card.text.localized(locale),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            if (card.ageRating == '18+') ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerRight,
                child: _AgeBadge(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          type.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _AgeBadge extends StatelessWidget {
  const _AgeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '18+',
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
