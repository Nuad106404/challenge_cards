import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_provider.dart';
import '../game/game_screen.dart';
import '../settings/settings_screen.dart';
import '../../models/game_mode_model.dart';
import '../../repositories/mode_repository.dart';
import 'home_background.dart';
import 'mode_card.dart';
import 'ambient_glow_layer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GameModeModel> _modes = [];
  bool _modesLoading = true;
  String? _modesError;

  final Map<int, GlobalKey> _cardKeys = {};
  Rect? _selectedCardRect;
  Color _selectedAccentColor = const Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    _loadModes();
  }

  Future<void> _loadModes() async {
    try {
      final modes = await ModeRepository.instance.getModes();
      if (mounted) {
        setState(() {
          _modes = modes;
          _modesLoading = false;
          // Initialize keys for each mode
          for (int i = 0; i < modes.length; i++) {
            _cardKeys[i] = GlobalKey();
          }
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _modesError = 'Failed to load modes';
          _modesLoading = false;
        });
    }
  }

  void _updateSelectedCardRect(int? selectedIndex) {
    if (selectedIndex == null) {
      setState(() {
        _selectedCardRect = null;
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _cardKeys[selectedIndex];
      if (key?.currentContext != null) {
        final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null && mounted) {
          final position = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          setState(() {
            _selectedCardRect = Rect.fromLTWH(
              position.dx,
              position.dy,
              size.width,
              size.height,
            );
            _selectedAccentColor = modeAccent(selectedIndex);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEDE0F8),
      body: Stack(
        children: [
          // ── Immersive background ───────────────────────────────────
          const Positioned.fill(child: HomeBackground()),

          // ── Ambient floating orbs ──────────────────────────────────
          const Positioned(
            top: -40,
            right: -30,
            child: AmbientOrb(
              color: Color(0x30FF4D8D),
              size: 220,
              duration: Duration(seconds: 7),
              dx: 20,
              dy: 18,
            ),
          ),
          const Positioned(
            bottom: 60,
            left: -50,
            child: AmbientOrb(
              color: Color(0x226C63FF),
              size: 260,
              duration: Duration(seconds: 9),
              dx: -16,
              dy: 22,
            ),
          ),

          // ── Ambient glow behind selected card ─────────────────────
          AmbientGlowLayer(
            targetRect: _selectedCardRect,
            accentColor: _selectedAccentColor,
            visible: _selectedCardRect != null,
          ),

          // ── Content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Eyebrow
                            Text(
                              'CHALLENGE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF4D8D)
                                    .withValues(alpha: 0.85),
                                letterSpacing: 4.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Main title with gradient simulation via foreground
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF2D1B4E), Color(0xFF6C3483)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'Cards',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 0.95,
                                  letterSpacing: -2.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings button
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, SettingsScreen.routeName),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: Color(0xFF2D1B4E),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ── Sub-label ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'Choose your play style',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2D1B4E).withValues(alpha: 0.55),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Mode tiles ───────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _modesLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF4D8D),
                              strokeWidth: 2,
                            ),
                          )
                        : _modesError != null
                            ? Center(
                                child: Text(
                                  _modesError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : _modes.isEmpty
                                ? Center(
                                    child: Text(
                                      'No modes available.',
                                      style: TextStyle(
                                        color: const Color(0xFF2D1B4E)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: _modes.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (context, i) {
                                      final m = _modes[i];
                                      final locale = gameProvider.locale;
                                      final isSelected =
                                          gameProvider.selectedMode?.slug ==
                                              m.slug;

                                      return ModeCard(
                                        key: ValueKey(m.slug),
                                        label: m.localizedName(locale),
                                        description:
                                            m.localizedDescription(locale),
                                        selected: isSelected,
                                        index: i,
                                        cardKey: _cardKeys[i],
                                        onTap: () async {
                                          gameProvider.setMode(m);
                                          _updateSelectedCardRect(i);
                                          await gameProvider.startGame([]);
                                          if (!context.mounted) return;
                                          if (gameProvider.state ==
                                              GameState.playing) {
                                            Navigator.pushNamed(
                                                context, GameScreen.routeName);
                                          }
                                        },
                                      );
                                    },
                                  ),
                  ),
                ),

                // ── Error message ────────────────────────────────────
                if (gameProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      gameProvider.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
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
