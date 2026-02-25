import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/utils/haptic_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DiceRoller
// Shows [count] dice. Shake the device to roll all of them with animation.
// ─────────────────────────────────────────────────────────────────────────────

const _kShakeThreshold = 12.0; // delta m/s² between consecutive readings
const _kShakeCooldown = Duration(milliseconds: 800);

class DiceRoller extends StatefulWidget {
  final int count;

  const DiceRoller({super.key, required this.count});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> with TickerProviderStateMixin {
  final _rng = Random();
  late List<int> _values;
  late List<AnimationController> _shakeControllers;
  late List<Animation<double>> _shakeAnims;

  // Looping glow pulse during roll
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim; // 0.0 → 1.0 → 0.0

  // Vertical bounce during roll
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim; // 0 → -10 → 0 px

  bool _rolling = false;
  bool _disposed = false;
  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _lastX = 0, _lastY = 0, _lastZ = 0;

  @override
  void initState() {
    super.initState();
    _values = List.generate(widget.count, (_) => _rng.nextInt(6) + 1);
    _buildControllers();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    _accelSub = accelerometerEventStream().listen(_onAccelerometer);
  }

  void _onAccelerometer(AccelerometerEvent event) {
    if (_disposed) return;
    final dx = (event.x - _lastX).abs();
    final dy = (event.y - _lastY).abs();
    final dz = (event.z - _lastZ).abs();
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;
    final delta = dx + dy + dz;
    final now = DateTime.now();
    if (delta > _kShakeThreshold &&
        now.difference(_lastShake) > _kShakeCooldown) {
      _lastShake = now;
      _roll();
    }
  }

  void _buildControllers() {
    _shakeControllers = List.generate(
      widget.count,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _shakeAnims = _shakeControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 12.0, end: -10.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    _disposed = true;
    _accelSub?.cancel();
    _accelSub = null;
    _glowCtrl.dispose();
    _bounceCtrl.dispose();
    for (final c in _shakeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _alive => mounted && !_disposed;

  Future<void> _roll() async {
    if (_rolling || !_alive) return;
    _rolling = true;
    HapticHelper.light();

    // Start looping glow pulse + bounce
    _glowCtrl.repeat();
    _bounceCtrl.repeat();

    // Start shake animations
    for (final ctrl in _shakeControllers) {
      ctrl.reset();
      ctrl.forward();
    }

    // Rapid value flicker
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_alive) {
        _rolling = false;
        return;
      }
      setState(() {
        _values = List.generate(widget.count, (_) => _rng.nextInt(6) + 1);
      });
    }

    // Final values
    if (!_alive) {
      _rolling = false;
      return;
    }
    setState(() {
      _values = List.generate(widget.count, (_) => _rng.nextInt(6) + 1);
    });

    // Stop animations and snap back
    await Future.delayed(const Duration(milliseconds: 200));
    if (_alive) {
      HapticHelper.light();
      _glowCtrl.stop();
      _glowCtrl.reset();
      _bounceCtrl.stop();
      _bounceCtrl.reset();
    }
    _rolling = false;
  }

  int get _sum => _values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _roll,
      // Outer AnimatedBuilder drives glow halo + bounce from the two controllers
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowCtrl, _bounceCtrl]),
        builder: (context, child) {
          final pulse = _glowAnim.value;       // 0.0 → 1.0 → 0.0 looping
          final bounce = _bounceAnim.value;    // 0 → -10 → 0 looping

          // Die shadow: blur 6→28, alpha 0x80→0xE6
          final shadowBlur = 6.0 + pulse * 22.0;
          final shadowAlpha = (0x80 + (pulse * 0x66)).round().clamp(0, 255);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dice container (no halo)
              Container(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: List.generate(widget.count, (i) {
                    return AnimatedBuilder(
                      animation: _shakeControllers[i],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _shakeAnims[i].value,
                            bounce, // vertical bounce
                          ),
                          child: child,
                        );
                      },
                      child: _DieFace(
                        value: _values[i],
                        shadowBlur: shadowBlur,
                        shadowAlpha: shadowAlpha,
                      ),
                    );
                  }),
                ),
              ),
              // Sum display (only when more than 1 die)
              if (widget.count > 1) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xE6FFFFFF),
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Text(
                        '$_sum',
                        key: ValueKey(_sum),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xE6FFFFFF),
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Hint row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.vibration_rounded,
                    size: 13,
                    color: Color(0x99FFFFFF),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'SHAKE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0x99FFFFFF),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '·',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0x66FFFFFF),
                        height: 1,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.touch_app_rounded,
                    size: 13,
                    color: Color(0x99FFFFFF),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'TAP TO ROLL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0x99FFFFFF),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DieFace — renders a single die with dots
// ─────────────────────────────────────────────────────────────────────────────

class _DieFace extends StatelessWidget {
  final int value;
  final double shadowBlur;
  final int shadowAlpha;

  const _DieFace({
    required this.value,
    this.shadowBlur = 6.0,
    this.shadowAlpha = 0x80,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child, // pure scale — no opacity, avoids Impeller CanAcceptOpacity error
      ),
      child: Container(
        key: ValueKey(value),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE8E8F0),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000), // black 30%
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: const Color(0xCCFFFFFF), // white 80%
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Top-left highlight for 3D effect
            Positioned(
              top: 4,
              left: 4,
              right: 24,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xB3FFFFFF), // white 70%
                      Color(0x00FFFFFF), // white 0%
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _DotLayout(value: value),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DotLayout — renders the correct dot pattern for 1–6
// ─────────────────────────────────────────────────────────────────────────────

class _DotLayout extends StatelessWidget {
  final int value;
  const _DotLayout({required this.value});

  static const _dot = _Dot();

  // Each face is a 3x3 grid. true = dot, false = empty.
  static const _faces = <int, List<bool>>{
    1: [
      false, false, false,
      false, true,  false,
      false, false, false,
    ],
    2: [
      true,  false, false,
      false, false, false,
      false, false, true,
    ],
    3: [
      true,  false, false,
      false, true,  false,
      false, false, true,
    ],
    4: [
      true,  false, true,
      false, false, false,
      true,  false, true,
    ],
    5: [
      true,  false, true,
      false, true,  false,
      true,  false, true,
    ],
    6: [
      true,  false, true,
      true,  false, true,
      true,  false, true,
    ],
  };

  @override
  Widget build(BuildContext context) {
    final cells = _faces[value] ?? _faces[1]!;
    // Plain Column/Row — avoids GridView's full Sliver/ScrollView overhead
    // for a static 3x3 grid that never scrolls.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (col) {
            final idx = row * 3 + col;
            return Padding(
              padding: const EdgeInsets.all(1),
              child: SizedBox(
                width: 14,
                height: 14,
                child: cells[idx] ? _dot : null,
              ),
            );
          }),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000), // black 30%
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
