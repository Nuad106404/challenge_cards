import '../core/services/api_service.dart';
import '../core/services/cache_service.dart';
import '../models/card_model.dart';

class CardRepository {
  CardRepository._();
  static final CardRepository instance = CardRepository._();

  final _api = ApiService.instance;
  final _cache = CacheService.instance;

  Future<List<CardModel>> getCards({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.getCards();
      if (cached != null) {
        return CardModel.listFromJsonString(cached);
      }
    }

    final data = await _api.get('/public/cards') as List<dynamic>;
    final cards = CardModel.listFromJson(data);
    await _cache.setCards(CardModel.listToJsonString(cards));
    return cards;
  }

  Future<List<CardModel>> getCardsForPack(
    String packId, {
    bool include18Plus = false,
    bool forceRefresh = false,
  }) async {
    final all = await getCards(forceRefresh: forceRefresh);
    return all.where((c) {
      if (c.packId != packId) return false;
      if (!c.isActive) return false;
      if (c.status != 'published') return false;
      if (!include18Plus && c.ageRating == '18+') return false;
      return true;
    }).toList();
  }

  Future<List<CardModel>> getCardsForPacks(
    List<String> packIds, {
    bool include18Plus = false,
    bool forceRefresh = false,
  }) async {
    final all = await getCards(forceRefresh: forceRefresh);
    return all.where((c) {
      if (!packIds.contains(c.packId)) return false;
      if (!c.isActive) return false;
      if (c.status != 'published') return false;
      if (!include18Plus && c.ageRating == '18+') return false;
      return true;
    }).toList();
  }
}
