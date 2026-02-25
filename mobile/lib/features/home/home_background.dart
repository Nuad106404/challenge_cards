import 'dart:math' show Random, sin, pi;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeBackground — soft radial gradient + parallax movement + noise overlay
// ─────────────────────────────────────────────────────────────────────────────

class HomeBackground extends StatefulWidget {
  const HomeBackground({super.key});

  @override
  State<HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<HomeBackground>
    with SingleTickerProviderStateMixin {
  Offset _parallaxOffset = Offset.zero;
  late AnimationController _springBackCtrl;
  late Animation<Offset> _springBackAnim;

  @override
  void initState() {
    super.initState();
    _springBackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _springBackAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _springBackCtrl,
      curve: Curves.easeOutCubic,
    ));
    _springBackAnim.addListener(() {
      setState(() {
        _parallaxOffset = _springBackAnim.value;
      });
    });
  }

  @override
  void dispose() {
    _springBackCtrl.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dx = (event.position.dx - centerX) / centerX;
    final dy = (event.position.dy - centerY) / centerY;
    final next = Offset(dx * 12, dy * 12);
    // Only rebuild when offset changes by more than 1 logical pixel —
    // prevents 60-120 setState calls/sec on every raw pointer event.
    if ((next - _parallaxOffset).distanceSquared < 1.0) return;
    setState(() {
      _parallaxOffset = next;
    });
  }

  void _onPointerUp(PointerEvent event) {
    _springBackAnim = Tween<Offset>(
      begin: _parallaxOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _springBackCtrl,
      curve: Curves.easeOutCubic,
    ));
    _springBackCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: Stack(
        children: [
          // ── Radial gradient base (parallax layer 1: 12px max) ──────────
          Positioned.fill(
            child: Transform.translate(
              offset: _parallaxOffset,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.2, -0.6),
                    radius: 1.4,
                    colors: [
                      Color(0xFFEDE0F8), // soft lavender centre
                      Color(0xFFF5D6E8), // blush pink mid
                      Color(0xFFFFF3F0), // warm neutral edge
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Geometric blobs (parallax layer 2: 18px max) ───────────────
          Positioned.fill(
            child: Transform.translate(
              offset: _parallaxOffset * 1.5,
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    // Bottom-right warmth
                    Positioned(
                      bottom: -80,
                      right: -60,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x28FF8C42),
                              Color(0x00FF8C42),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Top-left cool tint
                  Positioned(
                    top: -60,
                    left: -40,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x206C63FF),
                            Color(0x006C63FF),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Large faint blob — center-right
                  Positioned(
                    top: 180,
                    right: -100,
                    child: Container(
                      width: 420,
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(210),
                        gradient: const RadialGradient(
                          colors: [
                            Color(0x08E8436A),
                            Color(0x00E8436A),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Large faint blob — bottom-left
                  Positioned(
                    bottom: -120,
                    left: -80,
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(190),
                        gradient: const RadialGradient(
                          colors: [
                            Color(0x064A90E2),
                            Color(0x004A90E2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),

          // ── Noise overlay (parallax layer 3: 6px max) ──────────────────
          Positioned.fill(
            child: Transform.translate(
              offset: _parallaxOffset * 0.5,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _NoisePainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoisePainter — static low-opacity grain for depth
// ─────────────────────────────────────────────────────────────────────────────

class _NoisePainter extends CustomPainter {
  static final List<_Grain> _grains = _buildGrains();

  static List<_Grain> _buildGrains() {
    final rng = Random(42);
    return List.generate(320, (_) => _Grain(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      r: 0.6 + rng.nextDouble() * 1.0,
      a: 0.02 + rng.nextDouble() * 0.045,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final g in _grains) {
      paint.color = Color.fromARGB(
        (g.a * 255).round(),
        120, 80, 160,
      );
      canvas.drawCircle(
        Offset(g.x * size.width, g.y * size.height),
        g.r,
        paint,
      );
    }

    // Subtle vignette — darken edges slightly
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          const Color(0x00000000),
          const Color(0x12000000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Grain {
  final double x, y, r, a;
  const _Grain({required this.x, required this.y, required this.r, required this.a});
}

// ─────────────────────────────────────────────────────────────────────────────
// Soft ambient orb — reusable floating glow widget
// ─────────────────────────────────────────────────────────────────────────────

class AmbientOrb extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final double dx;
  final double dy;

  const AmbientOrb({
    super.key,
    required this.color,
    required this.size,
    required this.duration,
    this.dx = 0,
    this.dy = 0,
  });

  @override
  State<AmbientOrb> createState() => _AmbientOrbState();
}

class _AmbientOrbState extends State<AmbientOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final t = _anim.value;
          final offsetX = sin(t * pi) * widget.dx;
          final offsetY = sin(t * pi * 0.7) * widget.dy;
          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color,
                    widget.color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
