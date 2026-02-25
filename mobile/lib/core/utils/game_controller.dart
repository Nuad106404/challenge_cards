import 'dart:math' show Random;
import '../../models/card_model.dart';
import '../../models/pack_model.dart';
import '../../repositories/card_repository.dart';
import '../../repositories/pack_repository.dart';

enum CardAction { done, skip, next }

class GameSession {
  final List<String> players;
  final String modeSlug;
  final bool include18Plus;
  final List<PackModel> packs;

  /// Cards in fixed sequential order (shuffled once on session creation).
  final List<CardModel> cards;

  /// Cursor into [cards]. Always >= 0 after construction.
  int currentCardIndex;

  /// Cursor into [players]. Advances sequentially.
  int currentPlayerIndex;

  GameSession({
    required this.players,
    required this.modeSlug,
    required this.include18Plus,
    required this.packs,
    required this.cards,
  })  : currentCardIndex = 0,
        currentPlayerIndex = 0;

  bool get hasCards => cards.isNotEmpty;

  bool get hasPrevious => currentCardIndex > 0;

  String get currentPlayer =>
      players.isNotEmpty ? players[currentPlayerIndex % players.length] : '';

  CardModel? get currentCard =>
      cards.isNotEmpty && currentCardIndex < cards.length
          ? cards[currentCardIndex]
          : null;

  /// Advance to the next card (wraps around). Rotates player.
  void next() {
    if (cards.isEmpty) return;
    currentCardIndex = (currentCardIndex + 1) % cards.length;
    if (players.isNotEmpty) {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }
  }

  /// Go back to the previous card. Does not change player.
  void goBack() {
    if (currentCardIndex > 0) {
      currentCardIndex--;
    }
  }

  int get totalCards => cards.length;

  /// True when the player has just seen the last card in the deck.
  bool get isFinished => cards.isNotEmpty && currentCardIndex == cards.length - 1;

  /// Shuffle cards into a new random order and reset to the first card.
  /// Called automatically when the last card is advanced past.
  void reshuffle() {
    cards.shuffle(Random());
    currentCardIndex = 0;
    currentPlayerIndex = 0;
  }

  /// Returns up to [count] cards starting from the current position,
  /// used by CardStackView to render ghost layers behind the active card.
  List<CardModel> peekCards({int count = 3}) {
    if (cards.isEmpty) return [];
    final result = <CardModel>[];
    for (int i = 0; i < count && i < cards.length; i++) {
      final idx = (currentCardIndex + i) % cards.length;
      result.add(cards[idx]);
    }
    return result;
  }
}

class GameController {
  GameController._();
  static final GameController instance = GameController._();

  final _packRepo = PackRepository.instance;
  final _cardRepo = CardRepository.instance;

  Future<GameSession> createSession({
    required List<String> players,
    required String modeSlug,
    required bool include18Plus,
  }) async {
    final packs = await _packRepo.getPacksByMode(modeSlug, include18Plus: include18Plus);
    final packIds = packs.map((p) => p.id).toList();

    final cards = await _cardRepo.getCardsForPacks(
      packIds,
      include18Plus: include18Plus,
    );

    // Shuffle cards for randomized gameplay
    cards.shuffle();

    return GameSession(
      players: players,
      modeSlug: modeSlug,
      include18Plus: include18Plus,
      packs: packs,
      cards: cards,
    );
  }
}
