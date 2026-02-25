import 'dart:async';
import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'game_provider.dart';
import '../../core/utils/game_controller.dart';
import '../../core/services/ads_service.dart';
import '../../core/services/config_service.dart';
import '../../models/local_ad_model.dart';
import '../../repositories/local_ad_repository.dart';
import '../../core/utils/image_preloader.dart';
import '../../widgets/card_stack_view.dart';
import '../../widgets/player_selector.dart';
import '../../widgets/swipe_hand_hint_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  BannerAd? _bannerAd;
  late AnimationController _bgController;

  List<LocalAdModel> _localAds = [];
  int _currentAdIndex = 0;
  Timer? _adRotationTimer;

  int _lastPrecachedIndex = -1;

  @override
  void initState() {
    super.initState();
    AdsService.instance.loadBanner(
      onLoaded: (ad) {
        if (mounted) setState(() => _bannerAd = ad);
      },
    );
    _fetchLocalAds();
    
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  Future<void> _fetchLocalAds() async {
    try {
      final ads = await LocalAdRepository.instance.fetchActiveAds();
      if (!mounted) return;
      setState(() => _localAds = ads);
      if (ads.isNotEmpty) {
        _startAdRotation();
      }
    } catch (_) {
      // Silently fall back to AdMob
    }
  }

  void _startAdRotation() {
    _adRotationTimer?.cancel();
    if (_localAds.isEmpty || !mounted) return;
    
    // Get global rotation duration from config
    final config = ConfigService.instance.current;
    final duration = Duration(seconds: config?.adRotationDuration ?? 5);
    
    _adRotationTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() {
        // Strictly alternate: even index = local ad, odd index = AdMob
        // Total cycle = localAds.length * 2 slots
        final totalSlots = _localAds.length * 2;
        _currentAdIndex = (_currentAdIndex + 1) % totalSlots;
      });
      _startAdRotation();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _adRotationTimer?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  void _confirmEnd(GameProvider provider) {
    clearPrecacheTracking();
    provider.endGame();
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  void _maybePrecache(GameSession session) {
    final idx = session.currentCardIndex;
    if (idx == _lastPrecachedIndex) return;
    _lastPrecachedIndex = idx;
    final urls = session.cards
        .map((c) => c.contentSource == 'image' && c.imageUrl != null
            ? _resolveImageUrl(c.imageUrl!)
            : '')
        .toList();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheNextCardImages(
        context: context,
        urls: urls,
        currentIndex: idx,
        countAhead: 3,
      );
    });
  }

  static final _apiSuffixRe = RegExp(r'/api$');

  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url.replaceAll('localhost', '10.0.2.2');
    final apiBase = (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3001')
        .replaceAll(_apiSuffixRe, '');
    return '$apiBase$url';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final session = provider.session;

    if (session == null || !session.hasCards) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No cards available for this mode.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    _maybePrecache(session);

    final stackCards = session.peekCards(count: 3);
    final progress =
        (session.currentCardIndex + 1) / session.totalCards.clamp(1, 9999);

    return Scaffold(
      body: Stack(
        children: [
          // ── Abstract background ────────────────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: _AbstractBackground(controller: _bgController),
            ),
          ),
          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Close button
                      _CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => _confirmEnd(provider),
                      ),
                      const SizedBox(width: 12),
                      // Progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.pink.shade100,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF4D8D),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.currentCardIndex + 1} of ${session.totalCards}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.pink.shade300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Player selector ────────────────────────────────────────
                if (session.players.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: PlayerSelector(
                      playerName: session.currentPlayer,
                      playerIndex: session.currentPlayerIndex,
                      totalPlayers: session.players.length,
                    ),
                  ),

                // ── Card stack ─────────────────────────────────────────────
                Expanded(
                  child: stackCards.isEmpty
                      ? const Center(child: Text('No card available'))
                      : SwipeHandHintOverlay(
                          child: CardStackView(
                            cards: stackCards,
                            playerName: session.currentPlayer,
                            hasPrevious: provider.hasPrevious,
                            onNext: () => provider.next(),
                            onPrevious: () => provider.previous(),
                          ),
                        ),
                ),

                // ── Banner ad (local banner takes priority over AdMob) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _LocalOrAdmobBanner(
                    bannerAd: _bannerAd,
                    localAds: _localAds,
                    currentAdIndex: _currentAdIndex,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFFFF4D8D)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LocalOrAdmobBanner — shows local image banner if configured, else AdMob
// ─────────────────────────────────────────────────────────────────────────────

class _LocalOrAdmobBanner extends StatelessWidget {
  final BannerAd? bannerAd;
  final List<LocalAdModel> localAds;
  final int currentAdIndex;

  const _LocalOrAdmobBanner({
    required this.bannerAd,
    required this.localAds,
    required this.currentAdIndex,
  });

  String _resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    String apiBase = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3001';
    if (apiBase.endsWith('/api')) apiBase = apiBase.substring(0, apiBase.length - 4);
    return '$apiBase$url';
  }

  Future<void> _openLink(String linkUrl) async {
    if (linkUrl.isEmpty) return;
    final uri = Uri.tryParse(linkUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalAds = localAds.isNotEmpty;
    final hasAdMob = bannerAd != null;

    // Strictly alternate: even slot = local ad, odd slot = AdMob
    if (hasLocalAds && hasAdMob) {
      final totalSlots = localAds.length * 2;
      final slot = currentAdIndex % totalSlots;
      final isAdMobSlot = slot.isOdd;

      if (!isAdMobSlot) {
        final ad = localAds[(slot ~/ 2) % localAds.length];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: GestureDetector(
            key: ValueKey('local_${ad.id}'),
            onTap: () => _openLink(ad.linkUrl),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: SizedBox(
                width: 320,
                height: 50,
                child: Image.network(
                  _resolveUrl(ad.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      } else {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Container(
            key: const ValueKey('admob'),
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: AdWidget(ad: bannerAd!),
          ),
        );
      }
    }

    // Show only local ads if available
    if (hasLocalAds) {
      final ad = localAds[currentAdIndex % localAds.length];
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: GestureDetector(
          key: ValueKey(ad.id),
          onTap: () => _openLink(ad.linkUrl),
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: SizedBox(
              width: 320,
              height: 50,
              child: Image.network(
                _resolveUrl(ad.imageUrl),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    }

    // Show only AdMob if available
    if (hasAdMob) {
      return Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        child: AdWidget(ad: bannerAd!),
      );
    }

    // Show nothing if neither is available
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AbstractBackground — animated geometric background shared across screens
// ─────────────────────────────────────────────────────────────────────────────

class _AbstractBackground extends StatelessWidget {
  final AnimationController controller;
  const _AbstractBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _AbstractBgPainter(t: controller.value),
      ),
    );
  }
}

class _AbstractBgPainter extends CustomPainter {
  final double t;
  const _AbstractBgPainter({required this.t});

  // Hoisted paints — created once per painter instance, not per frame.
  static final _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  static final _dotPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t2pi = t * 2 * pi;

    // ── Base gradient fill ─────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFCEEF5),
          Color(0xFFF5E6F8),
          Color(0xFFFFF0F5),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // ── Slow sine wave — top band ──────────────────────────────────────────
    _stroke
      ..color = const Color(0x18FF4D8D)
      ..strokeWidth = 1.2;
    final wave1 = Path();
    for (double x = 0; x <= w; x += 2) {
      final y = h * 0.18 + sin((x / w) * 2 * pi + t2pi) * 28;
      if (x == 0) wave1.moveTo(x, y); else wave1.lineTo(x, y);
    }
    canvas.drawPath(wave1, _stroke);

    // ── Second wave — lower ────────────────────────────────────────────────
    _stroke
      ..color = const Color(0x126C63FF)
      ..strokeWidth = 1.0;
    final wave2 = Path();
    for (double x = 0; x <= w; x += 2) {
      final y = h * 0.72 + sin((x / w) * 2 * pi - t2pi * 0.7 + 1.2) * 22;
      if (x == 0) wave2.moveTo(x, y); else wave2.lineTo(x, y);
    }
    canvas.drawPath(wave2, _stroke);

    // ── Large rotating triangle — top-right ────────────────────────────────
    _stroke
      ..color = const Color(0x14FF4D8D)
      ..strokeWidth = 1.4;
    canvas.save();
    canvas.translate(w * 0.82, h * 0.14);
    canvas.rotate(t2pi * 0.08);
    canvas.drawPath(Path()
      ..moveTo(0, -90)..lineTo(78, 45)..lineTo(-78, 45)..close(), _stroke);
    canvas.restore();

    // ── Medium triangle — bottom-left ──────────────────────────────────────
    _stroke
      ..color = const Color(0x0F9C27B0)
      ..strokeWidth = 1.2;
    canvas.save();
    canvas.translate(w * 0.12, h * 0.78);
    canvas.rotate(-t2pi * 0.06 + 0.4);
    canvas.drawPath(Path()
      ..moveTo(0, -70)..lineTo(60, 35)..lineTo(-60, 35)..close(), _stroke);
    canvas.restore();

    // ── Rotating diamond — center-right ───────────────────────────────────
    _stroke
      ..color = const Color(0x16FF8C42)
      ..strokeWidth = 1.0;
    canvas.save();
    canvas.translate(w * 0.88, h * 0.52 + sin(t2pi) * 20);
    canvas.rotate(t2pi * 0.12);
    canvas.drawPath(Path()
      ..moveTo(0, -44)..lineTo(26, 0)..lineTo(0, 44)..lineTo(-26, 0)..close(), _stroke);
    canvas.restore();

    // ── Hexagon — left mid ─────────────────────────────────────────────────
    _stroke
      ..color = const Color(0x126C63FF)
      ..strokeWidth = 1.0;
    const hR = 32.0;
    canvas.save();
    canvas.translate(w * 0.1 + sin(t2pi * 0.3 + pi / 2) * 10, h * 0.42);
    canvas.rotate(t2pi * 0.05);
    final hex = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 30) * pi / 180;
      final px = hR * sin(a + pi / 2);
      final py = hR * sin(a);
      if (i == 0) hex.moveTo(px, py); else hex.lineTo(px, py);
    }
    hex.close();
    canvas.drawPath(hex, _stroke);
    canvas.restore();

    // ── Diagonal grid lines ────────────────────────────────────────────────
    _stroke
      ..color = const Color(0x07000000)
      ..strokeWidth = 0.7;
    const spacing = 36.0;
    final total = w + h;
    for (double d = -h; d < total; d += spacing) {
      canvas.drawLine(Offset(d, 0), Offset(d + h, h), _stroke);
    }

    // ── Dot grid — pulse alpha only, no per-dot object alloc ──────────────
    const dotSpacing = 40.0;
    const dotR = 1.8;
    for (double x = dotSpacing / 2; x < w; x += dotSpacing) {
      for (double y = dotSpacing / 2; y < h; y += dotSpacing) {
        final pulse = 0.5 + 0.5 * sin(t2pi + (x + y) / 120);
        _dotPaint.color = Color.fromARGB(
          (pulse * 0x18).round(),
          0xFF, 0x4D, 0x8D,
        );
        canvas.drawCircle(Offset(x, y), dotR, _dotPaint);
      }
    }

    // ── Accent arc — bottom-right ──────────────────────────────────────────
    _stroke
      ..color = const Color(0x14FF4D8D)
      ..strokeWidth = 1.6;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w + sin(t2pi * 0.5) * 15, h),
        width: w * 0.75,
        height: w * 0.75,
      ),
      pi + 0.3, 0.9, false, _stroke,
    );

    // ── Small accent square — top-left ────────────────────────────────────
    _stroke
      ..color = const Color(0x1811998E)
      ..strokeWidth = 1.0;
    canvas.save();
    canvas.translate(w * 0.08, h * 0.08);
    canvas.rotate(t2pi * 0.15);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 28, height: 28),
      _stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AbstractBgPainter old) => old.t != t;
}

