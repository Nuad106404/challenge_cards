import '../core/services/api_service.dart';
import '../core/services/cache_service.dart';
import '../models/pack_model.dart';

class PackRepository {
  PackRepository._();
  static final PackRepository instance = PackRepository._();

  final _api = ApiService.instance;
  final _cache = CacheService.instance;

  Future<List<PackModel>> getPacks({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.getPacks();
      if (cached != null) {
        return PackModel.listFromJsonString(cached);
      }
    }

    final data = await _api.get('/public/packs') as List<dynamic>;
    final packs = PackModel.listFromJson(data);
    await _cache.setPacks(PackModel.listToJsonString(packs));
    return packs;
  }

  Future<List<PackModel>> getPacksByMode(String mode, {bool include18Plus = false}) async {
    final all = await getPacks();
    return all.where((p) {
      if (!p.isActive) return false;
      if (p.mode != mode) return false;
      if (!include18Plus && p.ageRating == '18+') return false;
      return true;
    }).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
