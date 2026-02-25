import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config_service.dart';

// Test IDs from Google — used when no ID is configured anywhere
const _kTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
const _kTestInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  final _configService = ConfigService.instance;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  bool get _adsEnabled => _configService.adsEnabled;

  // Priority: admin config → .env (local dev) → Google test ID
  String get _bannerId {
    final fromConfig = _configService.admobBannerId;
    if (fromConfig.isNotEmpty) return fromConfig;
    return dotenv.env['ADMOB_BANNER_ID'] ?? _kTestBannerId;
  }

  String get _interstitialId {
    final fromConfig = _configService.admobInterstitialId;
    if (fromConfig.isNotEmpty) return fromConfig;
    return dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? _kTestInterstitialId;
  }

  Future<void> initialize() async {
    if (!_adsEnabled) return;
    await MobileAds.instance.initialize();
  }

  Future<void> loadBanner({
    required void Function(BannerAd ad) onLoaded,
    void Function(BannerAd ad, LoadAdError error)? onFailed,
  }) async {
    if (!_adsEnabled) return;

    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          onFailed?.call(ad as BannerAd, error);
        },
      ),
    );
    await _bannerAd!.load();
  }

  Future<void> loadInterstitial({
    void Function(InterstitialAd ad)? onLoaded,
    void Function(LoadAdError error)? onFailed,
  }) async {
    if (!_adsEnabled) return;

    await InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          onLoaded?.call(ad);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          onFailed?.call(error);
        },
      ),
    );
  }

  void showInterstitial({FullScreenContentCallback<InterstitialAd>? callback}) {
    if (!_adsEnabled || _interstitialAd == null) return;
    if (callback != null) {
      _interstitialAd!.fullScreenContentCallback = callback;
    }
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  BannerAd? get bannerAd => _adsEnabled ? _bannerAd : null;

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
