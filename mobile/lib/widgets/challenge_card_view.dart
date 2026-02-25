import 'dart:math' show cos, sin, pi;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../core/utils/haptic_helper.dart';
import '../features/game/game_provider.dart';
import '../models/card_model.dart';
import 'dice_roller.dart';
import 'swipe_hint_chip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kSwipeThreshold = 100.0;
const _kRotationFactor = 0.0010;
const _kSwipeDuration = Duration(milliseconds: 300);
const _kRevealDuration = Duration(milliseconds: 350);

// ─────────────────────────────────────────────────────────────────────────────
// Card type palette
// ─────────────────────────────────────────────────────────────────────────────

class _CardStyle {
  final List<Color> gradient;
  final Color labelBg;
  final Color labelFg;
  final String emoji;
  const _CardStyle({
    required this.gradient,
    required this.labelBg,
    required this.labelFg,
    required this.emoji,
  });
}

const _kTypeStyles = <String, _CardStyle>{
  'dare': _CardStyle(
    gradient: [Color(0xFFFF4D8D), Color(0xFFFF8C42)],
    labelBg: Color(0x33FFFFFF),
    labelFg: Colors.white,
    emoji: '🔥',
  ),
  'question': _CardStyle(
    gradient: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
    labelBg: Color(0x33FFFFFF),
    labelFg: Colors.white,
    emoji: '💬',
  ),
  'vote': _CardStyle(
    gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
    labelBg: Color(0x33FFFFFF),
    labelFg: Colors.white,
    emoji: '🗳️',
  ),
  'punishment': _CardStyle(
    gradient: [Color(0xFF2D1B4E), Color(0xFF6C3483)],
    labelBg: Color(0x33FFFFFF),
    labelFg: Colors.white,
    emoji: '💀',
  ),
  'bonus': _CardStyle(
    gradient: [Color(0xFFF7971E), Color(0xFFFFD200)],
    labelBg: Color(0x33FFFFFF),
    labelFg: Colors.white,
    emoji: '⭐',
  ),
  'minigame': _CardStyle(
    gradient: [Color(0xFFE91E63), Color(0xFF9C27B0)],
    labelBg: Color(0x33FFFFFF),
    labelFg: Colors.white,
    emoji: '🎮',
  ),
};

_CardStyle _styleFor(String type) =>
    _kTypeStyles[type.toLowerCase()] ??
    const _CardStyle(
      gradient: [Color(0xFFFF4D8D), Color(0xFFFF8C42)],
      labelBg: Color(0x33FFFFFF),
      labelFg: Colors.white,
      emoji: '🎴',
    );

// ─────────────────────────────────────────────────────────────────────────────
// ChallengeCardView
// ─────────────────────────────────────────────────────────────────────────────

/// A single interactive card that supports:
///   • Swipe left  → next card
///   • Swipe right → previous card (disabled when [onPrevious] is null)
///   • Open-reveal animation on mount (scale 0.92 → 1.0, easeOutBack)
///   • Card tilt while dragging
///   • Haptic feedback at swipe threshold
///   • Input lock during animation
class ChallengeCardView extends StatefulWidget {
  final CardModel card;
  final String playerName;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const ChallengeCardView({
    super.key,
    required this.card,
    required this.playerName,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<ChallengeCardView> createState() => _ChallengeCardViewState();
}

class _ChallengeCardViewState extends State<ChallengeCardView>
    with TickerProviderStateMixin {
  // ── Swipe ─────────────────────────────────────────────────────────────────
  late final AnimationController _swipeCtrl;
  double _dragX = 0;
  double _swipeDirection = 1.0;
  bool _swipeTriggered = false;
  bool _hapticFired = false;

  // ── Reveal ────────────────────────────────────────────────────────────────
  late final AnimationController _revealCtrl;
  late final Animation<double> _revealScale;

  // ── Glow effect ───────────────────────────────────────────────────────────
  late final AnimationController _glowCtrl;

  // ── Input lock ────────────────────────────────────────────────────────────
  bool get _locked => _swipeCtrl.isAnimating;

  // ── Cached per-card derived values ─────────────────────────────────────
  late _CardStyle _style;
  late Color _glowColor;

  void _updateCardCache() {
    _style = _styleFor(widget.card.type);
    _glowColor = Color.lerp(_style.gradient.first, _style.gradient.last, 0.5)!;
  }

  // ── Image URL resolver ───────────────────────────────────────────────────
  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    String apiBase = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3001';
    if (apiBase.endsWith('/api')) apiBase = apiBase.substring(0, apiBase.length - 4);
    return '$apiBase$url';
  }

  @override
  void initState() {
    super.initState();

    _swipeCtrl = AnimationController(vsync: this, duration: _kSwipeDuration);

    _revealCtrl = AnimationController(vsync: this, duration: _kRevealDuration);
    _revealScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutBack),
    );
    _revealCtrl.forward();
    _updateCardCache();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(ChallengeCardView old) {
    super.didUpdateWidget(old);
    if (old.card.type != widget.card.type) _updateCardCache();
  }

  @override
  void dispose() {
    _swipeCtrl.dispose();
    _revealCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Swipe logic ───────────────────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails d) {
    if (_locked || _swipeTriggered) return;
    setState(() {
      _dragX += d.delta.dx;
    });

    // Block right swipe when no previous card
    if (_dragX > 0 && widget.onPrevious == null) {
      setState(() { _dragX = 0; });
      return;
    }
    if (!_hapticFired && _dragX.abs() > _kSwipeThreshold) {
      _hapticFired = true;
      HapticHelper.light();
      // Trigger glow animation
      _glowCtrl.forward();
    }
    if (_dragX.abs() < _kSwipeThreshold) {
      _hapticFired = false;
      _glowCtrl.reverse();
    }
  }

  Future<void> _onPanEnd(DragEndDetails d) async {
    if (_locked || _swipeTriggered) return;

    final dx = _dragX;
    _dragX = 0;
    _hapticFired = false;

    if (dx.abs() < _kSwipeThreshold) {
      setState(() {});
      return;
    }

    _swipeDirection = dx > 0 ? 1.0 : -1.0;
    _swipeTriggered = true;
    setState(() {});

    _swipeCtrl.reset();
    await _swipeCtrl.forward();

    if (!mounted) return;
    if (_swipeDirection > 0) {
      widget.onPrevious?.call();
    } else {
      widget.onNext();
    }
  }

  void _onPanCancel() {
    if (_swipeTriggered) return;
    setState(() {
      _dragX = 0;
      _hapticFired = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<GameProvider>().locale;
    // Hoist MediaQuery + card-derived values outside the AnimatedBuilder so
    // they are not recomputed on every animation frame (60 fps).
    final screenWidth = MediaQuery.sizeOf(context).width;
    final swipeExitWidth = screenWidth + 200;

    return AnimatedBuilder(
      animation: Listenable.merge([_revealCtrl, _swipeCtrl, _glowCtrl]),
      builder: (context, _) {
        final revealS = _revealCtrl.isCompleted ? 1.0 : _revealScale.value;

        final swipeDx = _swipeTriggered
            ? Offset.lerp(
                Offset.zero,
                Offset(swipeExitWidth * _swipeDirection, 0),
                Curves.easeOutCubic.transform(_swipeCtrl.value),
              )!.dx
            : _dragX;

        final swipeDy = _swipeTriggered ? 0.0 : _dragX * 0.08;
        final rotation = swipeDx * _kRotationFactor;

        // Swipe hint opacity: fade in as drag approaches threshold
        final hintOpacity = (_dragX.abs() / _kSwipeThreshold).clamp(0.0, 1.0);
        final isSwipingLeft = _dragX < -10;
        final isSwipingRight = _dragX > 10 && widget.onPrevious != null;

        // Light reflection position based on drag
        final lightReflectionOffset = _dragX / screenWidth;

        return GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanCancel: _onPanCancel,
          child: Transform.translate(
            offset: Offset(swipeDx, swipeDy),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: revealS,
                child: Stack(
                  children: [
                    // Background glow when threshold reached
                    if (_glowCtrl.value > 0)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(
                                  (_glowCtrl.value * 255).round(),
                                  (_glowColor.r * 255).round(),
                                  (_glowColor.g * 255).round(),
                                  (_glowColor.b * 255).round(),
                                ),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Card shell with content
                    if (widget.card.contentSource == 'image' && widget.card.imageUrl != null)
                      // ── Image card: full-bleed image, bottom overlay only ──
                      _CardShell(
                        style: _style,
                        scale: revealS,
                        lightReflectionOffset: lightReflectionOffset,
                        imageUrl: _resolveImageUrl(widget.card.imageUrl!),
                        child: Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xCC000000), Color(0x00000000)],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.playerName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _TypeBadge(type: widget.card.type, style: _style),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      // ── Text card: original layout unchanged ──
                      _CardShell(
                        style: _style,
                        scale: revealS,
                        lightReflectionOffset: lightReflectionOffset,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top section: Emoji icon
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 600),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Transform.rotate(
                                        angle: (1 - value) * 0.5,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _style.emoji,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 64,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x33000000),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Middle section: Card text + optional dice
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.card.text.localized(locale),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.4,
                                          shadows: [
                                            Shadow(
                                              color: Color(0x55000000),
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (widget.card.ageRating == '18+') ...[
                                        const SizedBox(height: 16),
                                        const _AgeBadge(),
                                      ],
                                      if (widget.card.diceCount > 0) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          constraints: const BoxConstraints(maxHeight: 340),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0x26000000),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0x26FFFFFF),
                                              width: 1,
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            physics: const NeverScrollableScrollPhysics(),
                                            child: DiceRoller(count: widget.card.diceCount),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Bottom section: Player name and Type badge
                            Column(
                              children: [
                                Text(
                                  widget.playerName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _TypeBadge(type: widget.card.type, style: _style),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    // ── Swipe hint overlays (HUD style) ────────────────────
                    // Right swipe hint (NEXT) - upper right quadrant
                    if (isSwipingLeft)
                      Positioned(
                        top: 80,
                        right: 40,
                        child: SwipeHintChip(
                          label: 'NEXT',
                          icon: Icons.arrow_forward_rounded,
                          variant: SwipeHintVariant.right,
                          opacity: hintOpacity,
                        ),
                      ),
                    
                    // Left swipe hint (BACK) - upper left quadrant
                    if (isSwipingRight)
                      Positioned(
                        top: 80,
                        left: 40,
                        child: SwipeHintChip(
                          label: 'BACK',
                          icon: Icons.arrow_back_rounded,
                          variant: SwipeHintVariant.left,
                          opacity: hintOpacity,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final _CardStyle style;
  final double scale;
  final double lightReflectionOffset;
  final String? imageUrl;

  const _CardShell({
    required this.child,
    required this.style,
    required this.scale,
    required this.lightReflectionOffset,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic shadow intensity based on scale (depth)
    final shadowIntensity = scale; // 0.92 (background) to 1.0 (active)
    final isActive = scale > 0.96;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // Layer 1: Deep shadow
          BoxShadow(
            color: Color.fromARGB(
              (0.08 * shadowIntensity * 255).round(),
              (style.gradient.first.r * 255).round(),
              (style.gradient.first.g * 255).round(),
              (style.gradient.first.b * 255).round(),
            ),
            blurRadius: 20 * shadowIntensity,
            offset: Offset(0, 10 * shadowIntensity),
          ),
          // Layer 2: Mid-range shadow
          BoxShadow(
            color: Color.fromARGB(
              (0.04 * shadowIntensity * 255).round(),
              (style.gradient.last.r * 255).round(),
              (style.gradient.last.g * 255).round(),
              (style.gradient.last.b * 255).round(),
            ),
            blurRadius: 40 * shadowIntensity,
            offset: Offset(0, 20 * shadowIntensity),
          ),
          // Layer 3: Contact shadow
          BoxShadow(
            color: Color.fromARGB((0.15 * shadowIntensity * 255).round(), 0, 0, 0),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            // Subtle surface gradient (matte plastic feel)
            gradient: LinearGradient(
              colors: [
                style.gradient.first,
                Color.lerp(style.gradient.first, style.gradient.last, 0.5)!,
                style.gradient.last,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed image layer (image cards only)
              if (imageUrl != null)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                    fadeInDuration: const Duration(milliseconds: 150),
                    placeholder: (_, __) => const ColoredBox(color: Color(0x33000000)),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // Inner border (laminated edge reflection)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0x14FFFFFF),
                      width: 1,
                    ),
                  ),
                ),
              ),
              
              // Top light reflection (static)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isActive ? const Color(0x2EFFFFFF) : const Color(0x1FFFFFFF),
                        const Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom darkening
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0x14000000),
                        const Color(0x00000000),
                      ],
                    ),
                  ),
                ),
              ),

              // Animated light reflection following drag
              if (lightReflectionOffset.abs() > 0.01)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: (lightReflectionOffset * 300).clamp(-100.0, 400.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0x00FFFFFF),
                          const Color(0x14FFFFFF),
                          const Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),

              // Abstract geometric shapes + diagonal lines (hidden for image cards)
              if (imageUrl == null) ...
                [
                  // RepaintBoundary isolates the continuous geometry animation
                  // so it doesn't dirty the text/badge layers above it.
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: _AnimatedGeometry(
                        color: style.gradient.first,
                        seed: style.gradient.first.toARGB32(),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiagonalLinePainter(),
                    ),
                  ),
                ],

              // Content (no padding for image cards)
              if (imageUrl != null)
                child
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                  child: child,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final _CardStyle style;
  const _TypeBadge({required this.type, required this.style});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: style.labelBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Text(
          type.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: style.labelFg,
            letterSpacing: 2.0,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: const Text(
        '18+',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TappableButton — scale feedback 1.0 → 0.96 → 1.0
// ─────────────────────────────────────────────────────────────────────────────

class TappableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TappableButton({super.key, required this.child, this.onTap});

  @override
  State<TappableButton> createState() => _TappableButtonState();
}

class _TappableButtonState extends State<TappableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) async {
    await _ctrl.forward();
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    await _ctrl.reverse();
    widget.onTap?.call();
  }

  Future<void> _onTapCancel() async {
    await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedGeometry — abstract geometric shapes that float and rotate
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedGeometry extends StatefulWidget {
  final Color color;
  final int seed;
  const _AnimatedGeometry({required this.color, required this.seed});

  @override
  State<_AnimatedGeometry> createState() => _AnimatedGeometryState();
}

class _AnimatedGeometryState extends State<_AnimatedGeometry>
    with SingleTickerProviderStateMixin {
  // Single controller drives all three speeds via modular arithmetic.
  // One Ticker instead of three — saves 2 vsync registrations per card.
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // LCM(9,6,4) = 36 s full cycle; all three speeds fit within one controller.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = _ctrl.value; // 0.0 → 1.0 over 36 s
        // Derive the three independent oscillators:
        //   t1 cycles 4× per 36 s  (≈ 9 s period, reverse via triangle wave)
        //   t2 cycles 6× per 36 s  (≈ 6 s period)
        //   t3 cycles 9× per 36 s  (≈ 4 s period)
        final t1 = _tri(v * 4);
        final t2 = _tri(v * 6);
        final t3 = _tri(v * 9);
        return SizedBox.expand(
          child: CustomPaint(
            painter: _AbstractGeometryPainter(t1: t1, t2: t2, t3: t3),
          ),
        );
      },
    );
  }

  // Triangle wave: maps [0,1] → [0,1,0] to mimic reverse:true behaviour.
  static double _tri(double x) {
    final m = x % 2.0;
    return m < 1.0 ? m : 2.0 - m;
  }
}

class _AbstractGeometryPainter extends CustomPainter {
  final double t1;
  final double t2;
  final double t3;

  const _AbstractGeometryPainter({
    required this.t1,
    required this.t2,
    required this.t3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // ── Large corner triangle (top-right) ─────────────────────────────────
    paint
      ..color = const Color(0x18FFFFFF)
      ..strokeWidth = 1.5;
    final triOffset = Offset(t1 * 14 - 7, t1 * 10 - 5);
    final triPath = Path()
      ..moveTo(w - 20 + triOffset.dx, -10 + triOffset.dy)
      ..lineTo(w + 60 + triOffset.dx, h * 0.35 + triOffset.dy)
      ..lineTo(w * 0.55 + triOffset.dx, -10 + triOffset.dy)
      ..close();
    canvas.drawPath(triPath, paint);

    // ── Second triangle (bottom-left, filled faint) ────────────────────────
    paint
      ..color = const Color(0x0FFFFFFF)
      ..style = PaintingStyle.fill;
    final tri2Offset = Offset(t2 * -12 + 6, t2 * 16 - 8);
    final tri2Path = Path()
      ..moveTo(-30 + tri2Offset.dx, h * 0.6 + tri2Offset.dy)
      ..lineTo(w * 0.4 + tri2Offset.dx, h + 40 + tri2Offset.dy)
      ..lineTo(-30 + tri2Offset.dx, h + 40 + tri2Offset.dy)
      ..close();
    canvas.drawPath(tri2Path, paint);
    paint.style = PaintingStyle.stroke;

    // ── Rotating diamond (center-left) ────────────────────────────────────
    paint
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 1.2;
    final dAngle = t2 * 0.6;
    final dCx = w * 0.15;
    final dCy = h * 0.38 + t1 * 18 - 9;
    final dSize = 38.0 + t3 * 10;
    canvas.save();
    canvas.translate(dCx, dCy);
    canvas.rotate(dAngle);
    final diamondPath = Path()
      ..moveTo(0, -dSize)
      ..lineTo(dSize * 0.6, 0)
      ..lineTo(0, dSize)
      ..lineTo(-dSize * 0.6, 0)
      ..close();
    canvas.drawPath(diamondPath, paint);
    canvas.restore();

    // ── Small rotating square (top-left) ──────────────────────────────────
    paint
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 1.0;
    final sqAngle = t3 * 1.2;
    final sqCx = w * 0.22 + t2 * 12 - 6;
    final sqCy = h * 0.12;
    final sqSize = 22.0;
    canvas.save();
    canvas.translate(sqCx, sqCy);
    canvas.rotate(sqAngle);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: sqSize, height: sqSize), paint);
    canvas.restore();

    // ── Thin horizontal accent lines (mid-card) ───────────────────────────
    paint
      ..color = const Color(0x12FFFFFF)
      ..strokeWidth = 0.8;
    final lineY = h * 0.72 + t1 * 8 - 4;
    canvas.drawLine(Offset(w * 0.08, lineY), Offset(w * 0.38, lineY), paint);
    canvas.drawLine(Offset(w * 0.08, lineY + 6), Offset(w * 0.24, lineY + 6), paint);

    // ── Arc slice (bottom-right) ───────────────────────────────────────────
    paint
      ..color = const Color(0x16FFFFFF)
      ..strokeWidth = 1.4;
    final arcOffset = Offset(t2 * 10 - 5, t3 * 8 - 4);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w + arcOffset.dx, h + arcOffset.dy),
        width: w * 0.9,
        height: w * 0.9,
      ),
      3.4,
      1.1,
      false,
      paint,
    );

    // ── Dot cluster (upper-left area) ─────────────────────────────────────
    paint
      ..color = const Color(0x28FFFFFF)
      ..style = PaintingStyle.fill;
    final dotOffsetY = t3 * 10 - 5;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(w * 0.08 + i * 10.0, h * 0.22 + j * 10.0 + dotOffsetY),
          1.5,
          paint,
        );
      }
    }

    // ── Hexagon outline (right side, mid) ─────────────────────────────────
    paint
      ..style = PaintingStyle.stroke
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;
    final hCx = w * 0.88 + t1 * 8 - 4;
    final hCy = h * 0.55 + t2 * 12 - 6;
    const hR = 28.0;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * pi / 180;
      final px = hCx + hR * cos(angle);
      final py = hCy + hR * sin(angle);
      if (i == 0) hexPath.moveTo(px, py); else hexPath.lineTo(px, py);
    }
    hexPath.close();
    canvas.drawPath(hexPath, paint);
  }

  @override
  bool shouldRepaint(_AbstractGeometryPainter old) =>
      old.t1 != t1 || old.t2 != t2 || old.t3 != t3;
}

// ─────────────────────────────────────────────────────────────────────────────
// _DiagonalLinePainter — subtle hatching pattern overlay
// ─────────────────────────────────────────────────────────────────────────────

class _DiagonalLinePainter extends CustomPainter {
  const _DiagonalLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x07FFFFFF)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 28.0;
    final total = size.width + size.height;
    for (double d = -size.height; d < total; d += spacing) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

