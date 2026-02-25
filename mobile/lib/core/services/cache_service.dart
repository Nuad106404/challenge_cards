import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  static const _keyContentVersion = 'content_version';
  static const _keyPacks = 'cached_packs';
  static const _keyCards = 'cached_cards';
  static const _keyConfig = 'cached_config';
  static const _keyAppLocale = 'app_locale';
  static const _keyInclude18Plus = 'include_18_plus';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Content version ──────────────────────────────────────────────────────

  int getContentVersion() => _prefs.getInt(_keyContentVersion) ?? -1;

  Future<void> setContentVersion(int version) =>
      _prefs.setInt(_keyContentVersion, version);

  // ── Packs ─────────────────────────────────────────────────────────────────

  String? getPacks() => _prefs.getString(_keyPacks);

  Future<void> setPacks(String json) => _prefs.setString(_keyPacks, json);

  Future<void> clearPacks() => _prefs.remove(_keyPacks);

  // ── Cards ─────────────────────────────────────────────────────────────────

  String? getCards() => _prefs.getString(_keyCards);

  Future<void> setCards(String json) => _prefs.setString(_keyCards, json);

  Future<void> clearCards() => _prefs.remove(_keyCards);

  // ── Config ────────────────────────────────────────────────────────────────

  String? getConfig() => _prefs.getString(_keyConfig);

  Future<void> setConfig(String json) => _prefs.setString(_keyConfig, json);

  // ── Locale ────────────────────────────────────────────────────────────────

  String getLocale() => _prefs.getString(_keyAppLocale) ?? 'en';

  Future<void> setLocale(String locale) =>
      _prefs.setString(_keyAppLocale, locale);

  // ── 18+ preference ──────────────────────────────────────────────────────

  bool getInclude18Plus() => _prefs.getBool(_keyInclude18Plus) ?? false;

  Future<void> setInclude18Plus(bool value) =>
      _prefs.setBool(_keyInclude18Plus, value);

  // ── Full cache clear ──────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _prefs.remove(_keyPacks);
    await _prefs.remove(_keyCards);
    await _prefs.remove(_keyConfig);
    await _prefs.remove(_keyContentVersion);
  }
}
