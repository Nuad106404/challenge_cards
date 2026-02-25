import 'package:flutter/material.dart';

/// Swipe-gesture hint overlay shown at the start of every game session.
/// Animates a hand icon left/right for [maxLoops] cycles then auto-dismisses.
/// Tapping anywhere dismisses it immediately.
class SwipeHandHintOverlay extends StatefulWidget {
  final Widget child;
  final Duration maxDuration;
  final int maxLoops;

  const SwipeHandHintOverlay({
    super.key,
    required this.child,
    this.maxDuration = const Duration(seconds: 3),
    this.maxLoops = 1,
  });

  @override
  State<SwipeHandHintOverlay> createState() => _SwipeHandHintOverlayState();
}

class _SwipeHandHintOverlayState extends State<SwipeHandHintOverlay>
    with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  late AnimationController _controller;
  int _currentLoop = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _controller.addStatusListener(_onAnimationStatus);
    _controller.forward();

    // Auto-dismiss after maxDuration
    Future.delayed(widget.maxDuration, () {
      if (mounted && !_dismissed) _dismiss();
    });
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dismissed) {
      _currentLoop++;
      if (_currentLoop < widget.maxLoops) {
        _controller.forward(from: 0.0);
      } else {
        _dismiss();
      }
    }
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    if (mounted) setState(() {});
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_dismissed) _dismiss();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (!_dismissed)
            Positioned.fill(
              child: RepaintBoundary(
                child: _HandGestureHint(
                  controller: _controller,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HandGestureHint extends StatelessWidget {
  final AnimationController controller;

  const _HandGestureHint({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final t = controller.value;
            
            // Three smooth moves: right → left → right
            // Each segment occupies 1/3 of the timeline.
            // easeInOutCubic gives a natural decelerate-at-ends feel.
            const double kSwing = 52.0; // px travel each way
            const double kTilt  = 0.13; // radians (~7.5°)

            double offsetX;
            double rotation;

            if (t < 1 / 3) {
              // Segment 1: centre → right
              final p = Curves.easeInOutCubic.transform(t * 3);
              offsetX  =  p * kSwing;
              rotation =  p * kTilt;
            } else if (t < 2 / 3) {
              // Segment 2: right → left
              final p = Curves.easeInOutCubic.transform((t - 1 / 3) * 3);
              offsetX  =  kSwing - p * kSwing * 2; // +kSwing → -kSwing
              rotation =  kTilt  - p * kTilt  * 2;
            } else {
              // Segment 3: left → right
              final p = Curves.easeInOutCubic.transform((t - 2 / 3) * 3);
              offsetX  = -kSwing + p * kSwing * 2; // -kSwing → +kSwing
              rotation = -kTilt  + p * kTilt  * 2;
            }

            // Subtle scale pulse tied to speed (fastest at segment midpoints)
            final speedT = (t * 3) % 1.0;
            final scale  = 1.0 + 0.10 * (1 - (speedT * 2 - 1) * (speedT * 2 - 1));

            // Opacity pulses once per segment for attention
            final pulseOpacity = 0.80 + 0.20 * (1 - (speedT * 2 - 1) * (speedT * 2 - 1));

            return Center(
              child: Transform.translate(
                offset: Offset(0, 100), // Position near center-bottom of card
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glassmorphism container with hand
                    Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: rotation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0x40FFFFFF),
                                  Color(0x26FFFFFF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0x4DFFFFFF),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Color(0x1AFFFFFF),
                                  blurRadius: 10,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.pan_tool_alt_rounded,
                              size: 56,
                              // Encode pulseOpacity directly in the color alpha —
                              // avoids Opacity widget's per-frame saveLayer allocation.
                              color: Color.fromARGB(
                                (pulseOpacity * 255).round().clamp(0, 255),
                                255, 255, 255,
                              ),
                              shadows: const [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Modern "SWIPE" text with glow
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0x2EFFFFFF),
                            Color(0x17FFFFFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x3AFFFFFF),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'SWIPE TO PLAY',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.5,
                          shadows: const [
                            Shadow(
                              color: Color(0x88000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                            Shadow(
                              color: Colors.white,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
