import '../../models/config_model.dart';
import '../../repositories/config_repository.dart';
import 'api_service.dart';
import 'cache_service.dart';

class ConfigService {
  ConfigService._();
  static final ConfigService instance = ConfigService._();

  final _repo = ConfigRepository.instance;
  final _cache = CacheService.instance;

  ConfigModel? _current;

  ConfigModel? get current => _current;

  /// Called on app start. Returns true if content version changed (caller should refetch packs/cards).
  Future<bool> initialize() async {
    final cachedVersion = _cache.getContentVersion();

    // Try to load cached config first so app works offline
    final cachedJson = _cache.getConfig();
    if (cachedJson != null) {
      _current = ConfigModel.fromJsonString(cachedJson);
      // Apply the cached URL immediately — the fresh fetch itself and all
      // subsequent requests will use it instead of the .env bootstrap.
      ApiService.instance.updateBaseUrl(_current!.apiBaseUrl);
    }

    try {
      final fresh = await _repo.fetchConfig();
      await _cache.setConfig(fresh.toJsonString());
      _current = fresh;

      // Propagate the admin-configured API base URL to ApiService so all
      // subsequent requests use the remote URL instead of the .env bootstrap.
      ApiService.instance.updateBaseUrl(fresh.apiBaseUrl);

      final versionChanged = fresh.contentVersion != cachedVersion;
      if (versionChanged) {
        await _cache.setContentVersion(fresh.contentVersion);
      }
      return versionChanged;
    } catch (_) {
      // Offline — use cached; treat as no version change
      return false;
    }
  }

  bool get adsEnabled => _current?.adsEnabled ?? false;
  String get admobAppId => _current?.admobAppId ?? '';
  String get admobBannerId => _current?.admobBannerId ?? '';
  String get admobInterstitialId => _current?.admobInterstitialId ?? '';
  int get contentVersion => _current?.contentVersion ?? 0;
  String get apiBaseUrl => _current?.apiBaseUrl ?? '';
}
