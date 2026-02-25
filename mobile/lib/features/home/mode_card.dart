import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mode color system
// ─────────────────────────────────────────────────────────────────────────────

const _kModeAccents = [
  Color(0xFF4A90E2), // Friends — blue
  Color(0xFFE8436A), // Couple  — rose
  Color(0xFF11998E), // teal
  Color(0xFFFF8C42), // orange
  Color(0xFF9C27B0), // purple
];

Color modeAccent(int index) => _kModeAccents[index % _kModeAccents.length];

// ─────────────────────────────────────────────────────────────────────────────
// ModeCard — game tile with depth shadows, animated selected state
// ─────────────────────────────────────────────────────────────────────────────

class ModeCard extends StatefulWidget {
  final String label;
  final String description;
  final bool selected;
  final int index;
  final VoidCallback onTap;
  final GlobalKey? cardKey;

  const ModeCard({
    super.key,
    required this.label,
    required this.description,
    required this.selected,
    required this.index,
    required this.onTap,
    this.cardKey,
  });

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  bool _pressing = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressing = true);
  void _onTapUp(TapUpDetails _) {
    setState(() => _pressing = false);
    widget.onTap();
  }
  void _onTapCancel() => setState(() => _pressing = false);

  @override
  Widget build(BuildContext context) {
    final accent = modeAccent(widget.index);

    // AnimatedPadding is layout-safe: the card shrinks inward on press so it
    // never paints outside its slot — no overflow onto neighbouring cards.
    return AnimatedPadding(
      duration: Duration(milliseconds: _pressing ? 60 : 160),
      curve: _pressing ? Curves.easeOut : Curves.easeOutBack,
      padding: EdgeInsets.symmetric(
        horizontal: _pressing ? 4.0 : 0.0,
        vertical:   _pressing ? 2.0 : 0.0,
      ),
      child: GestureDetector(
        key: widget.cardKey,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: RepaintBoundary(
          child: _CardSurface(
            accent: accent,
            selected: widget.selected,
            label: widget.label,
            description: widget.description,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CardSurface — the visual tile body
// ─────────────────────────────────────────────────────────────────────────────

class _CardSurface extends StatelessWidget {
  final Color accent;
  final bool selected;
  final String label;
  final String description;

  const _CardSurface({
    required this.accent,
    required this.selected,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);

    // BoxDecoration.boxShadow paints the shadow as part of this widget's own
    // draw call — it is clipped by the ListView viewport and never bleeds over
    // neighbouring cards.  Material elevation is drawn in a separate pass that
    // ignores the scroll clip, which is what caused the overlap artifact.
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: selected
                ? Color.fromARGB(38, (accent.r * 255).round(), (accent.g * 255).round(), (accent.b * 255).round())
                : const Color(0x16000000),
            blurRadius: selected ? 18 : 10,
            spreadRadius: selected ? 1 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        // ClipRRect is safe here: the shadow is on the OUTER Container,
        // not on anything inside the clip — no saveLayer needed.
        borderRadius: radius,
        child: ColoredBox(
          // Opaque background behind content (no Ink/gradient saveLayer).
          color: const Color(0xFFFFFFFF),
          child: SizedBox(
            height: 118,
            child: Stack(
              children: [
                // card surface gradient — plain Container, no clip
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF8F6FC),
                        ],
                      ),
                    ),
                  ),
                ),

                // subtle border (inside clip — fine)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: selected
                            ? Color.fromARGB(40, (accent.r * 255).round(), (accent.g * 255).round(), (accent.b * 255).round())
                            : const Color(0x10000000),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // top sheen
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // accent bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 5,
                        height: selected ? 56 : 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent,
                              Color.lerp(accent, Colors.white, 0.3)!,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: TextStyle(
                                fontSize: selected ? 18 : 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A0E2E),
                                letterSpacing: -0.3,
                                height: 1.1,
                              ),
                              child: Text(label),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: selected
                                      ? Color.fromARGB(200, (accent.r * 255).round(), (accent.g * 255).round(), (accent.b * 255).round())
                                      : const Color(0x88000000),
                                  height: 1.35,
                                ),
                                child: Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}