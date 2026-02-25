import 'package:flutter/material.dart';

import '../models/card_model.dart';
import 'challenge_card_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// How many ghost cards are rendered behind the active card.
const _kStackDepth = 2;

/// Scale step between each stacked card layer (e.g. 0.04 = 4% smaller per layer).
const _kScaleStep = 0.04;

/// Vertical offset (px) applied per layer so cards peek below the active card.
const _kOffsetStep = 10.0;

/// Duration for the next-card scale-forward animation.
const _kStackAdvanceDuration = Duration(milliseconds: 320);

// ─────────────────────────────────────────────────────────────────────────────
// CardStackView
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a stack of [CardModel]s.
///
/// The top card is fully interactive via [ChallengeCardView].
/// The cards behind it are static ghost layers that animate forward
/// when the top card is dismissed (done / skip).
///
/// Usage:
/// ```dart
/// CardStackView(
///   cards: [currentCard, nextCard, nextNextCard],
///   playerName: session.currentPlayer,
///   onDone: () { ... },
///   onSkip: () { ... },
/// )
/// ```
class CardStackView extends StatefulWidget {
  /// Ordered list of cards to display. Index 0 = top (active) card.
  /// Provide at least 1; up to [_kStackDepth + 1] are rendered.
  final List<CardModel> cards;
  final String playerName;
  final bool hasPrevious;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const CardStackView({
    super.key,
    required this.cards,
    required this.playerName,
    required this.hasPrevious,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<CardStackView> createState() => _CardStackViewState();
}

class _CardStackViewState extends State<CardStackView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _advanceCtrl;

  /// Drives scale/offset of ghost cards from their "resting" position
  /// toward the "one step closer" position when the top card leaves.
  late final Animation<double> _advanceProgress;

  /// Key used to force [ChallengeCardView] to rebuild (reset its state)
  /// when the active card changes.
  Key _topCardKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _advanceCtrl = AnimationController(
      vsync: this,
      duration: _kStackAdvanceDuration,
    );
    _advanceProgress = CurvedAnimation(
      parent: _advanceCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _advanceCtrl.dispose();
    super.dispose();
  }

  // ── Dismiss handlers ──────────────────────────────────────────────────────

  Future<void> _handleNext() async {
    await _advanceCtrl.forward();
    _advanceCtrl.reset();
    setState(() {
      _topCardKey = UniqueKey();
    });
    widget.onNext();
  }

  Future<void> _handlePrevious() async {
    if (!widget.hasPrevious) return;
    _advanceCtrl.reset();
    setState(() {
      _topCardKey = UniqueKey();
    });
    widget.onPrevious();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    // Number of ghost layers to render (capped by available cards - 1)
    final ghostCount = (cards.length - 1).clamp(0, _kStackDepth);

    return AnimatedBuilder(
      animation: _advanceProgress,
      builder: (context, _) {
        final t = _advanceProgress.value; // 0 → 1 during advance

        return Stack(
          alignment: Alignment.center,
          children: [
            // ── Ghost cards (back to front) ──────────────────────────────
            for (int layer = ghostCount; layer >= 1; layer--)
              _GhostCard(
                card: cards[layer < cards.length ? layer : cards.length - 1],
                // Current resting depth for this layer
                currentDepth: layer,
                // Target depth after advance (one step closer)
                targetDepth: layer - 1,
                progress: t,
              ),

            // ── Active (top) card ────────────────────────────────────────
            ChallengeCardView(
              key: _topCardKey,
              card: cards[0],
              playerName: widget.playerName,
              onNext: _handleNext,
              onPrevious: widget.hasPrevious ? _handlePrevious : null,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GhostCard
// ─────────────────────────────────────────────────────────────────────────────

/// A non-interactive card rendered behind the active card.
/// Interpolates between [currentDepth] and [targetDepth] as [progress] → 1.
class _GhostCard extends StatelessWidget {
  final CardModel card;
  final int currentDepth;
  final int targetDepth;
  final double progress;

  const _GhostCard({
    required this.card,
    required this.currentDepth,
    required this.targetDepth,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final fromScale = 1.0 - currentDepth * _kScaleStep;
    final toScale = 1.0 - targetDepth * _kScaleStep;
    final scale = lerpDouble(fromScale, toScale, progress)!;

    final fromOffset = currentDepth * _kOffsetStep;
    final toOffset = targetDepth * _kOffsetStep;
    final offsetY = lerpDouble(fromOffset, toOffset, progress)!;

    final fromOpacity = 1.0 - currentDepth * 0.15;
    final toOpacity = 1.0 - targetDepth * 0.15;
    final opacity = lerpDouble(fromOpacity, toOpacity, progress)!.clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Transform.scale(
        scale: scale,
        child: _GhostCardShell(card: card, opacity: opacity),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GhostCardShell
// ─────────────────────────────────────────────────────────────────────────────

/// Static card back face used for ghost layers.
class _GhostCardShell extends StatelessWidget {
  final CardModel card;
  final double opacity;

  const _GhostCardShell({required this.card, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB((opacity * 255).round(), (surface.r * 255).round(), (surface.g * 255).round(), (surface.b * 255).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB((0x14 * opacity).round(), 0, 0, 0),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Match the height of the active card without rendering content
      child: const SizedBox(height: 420),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
