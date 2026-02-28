import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/config_service.dart';
import '../../models/config_model.dart' show SupportedLanguage;
import '../game/game_provider.dart';
import 'settings_section.dart';
import 'language_chip.dart';
import 'danger_action_card.dart';
import 'info_tile.dart';
import 'widgets/animated_toggle_glow.dart';
import 'widgets/section_entrance.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _section1Anim;
  late Animation<double> _section2Anim;
  late Animation<double> _section3Anim;
  late Animation<double> _section4Anim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Staggered intervals for each section
    _section1Anim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _section2Anim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
    );
    _section3Anim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOut),
    );
    _section4Anim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _setLocale(String locale) async {
    await CacheService.instance.setLocale(locale);
    setState(() {});
    if (mounted) context.read<GameProvider>().notifyLocaleChanged();
  }

  Future<void> _clearCache() async {
    await CacheService.instance.clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Cache cleared. Restart to reload content.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ConfigService.instance.current;
    final gameProvider = context.watch<GameProvider>();
    final currentLocale = CacheService.instance.getLocale();
    final languages = (config?.supportedLanguages == null ||
            config!.supportedLanguages.isEmpty)
        ? [const SupportedLanguage(code: 'en', label: 'English')]
        : config.supportedLanguages;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE0F8),
      body: Stack(
        children: [
          // ── Gradient background ────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEDE0F8), // light lavender
                    Color(0xFFF5D6E8), // pinkish neutral
                    Color(0xFFFFF3F0), // warm beige
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Bottom vignette ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x18000000),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF2D1B4E),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Game Settings',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D1B4E),
                          height: 1.0,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Control your experience',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D1B4E).withValues(alpha: 0.5),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Scrollable content ─────────────────────────────────
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    children: [
                      // ── 18+ Warning Card ───────────────────────────────
                      SectionEntrance(
                        animation: _section1Anim,
                        offsetY: 12,
                        child: SettingsSection(
                          title: 'Content Filter',
                          subtitle: 'Manage mature content visibility',
                          child: AnimatedToggleGlow(
                            enabled: gameProvider.include18Plus,
                            accentColor: const Color(0xFFE8436A),
                            child: _AdultModeCard(
                              enabled: gameProvider.include18Plus,
                              onToggle: (v) => gameProvider.setInclude18Plus(v),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Language Pills ─────────────────────────────────
                      SectionEntrance(
                        animation: _section2Anim,
                        offsetY: 10,
                        child: SettingsSection(
                          title: 'Language',
                          subtitle: 'Choose your preferred language',
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: languages
                                .map((lang) => LanguageChip(
                                      label: lang.label,
                                      code: lang.code,
                                      selected: currentLocale == lang.code,
                                      onTap: () => _setLocale(lang.code),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── App Info Stats ─────────────────────────────────
                      if (config != null) ...[
                        SectionEntrance(
                          animation: _section3Anim,
                          offsetY: 10,
                          child: SettingsSection(
                            title: 'App Information',
                            subtitle: 'Current version and status',
                            child: Column(
                              children: [
                                InfoTile(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Content Version',
                                  value: 'v${config.contentVersion}',
                                ),
                                const SizedBox(height: 10),
                                InfoTile(
                                  icon: Icons.phone_android_outlined,
                                  label: 'Min App Version',
                                  value: config.minAppVersion,
                                ),
                                const SizedBox(height: 10),
                                InfoTile(
                                  icon: Icons.ads_click_outlined,
                                  label: 'Ads Status',
                                  value: config.adsEnabled
                                      ? 'Enabled'
                                      : 'Disabled',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Clear Cache Danger Card ────────────────────────
                      SectionEntrance(
                        animation: _section4Anim,
                        offsetY: 10,
                        child: SettingsSection(
                          title: 'Data Management',
                          subtitle: 'Reset cached game content',
                          child: DangerActionCard(
                            title: 'Clear Game Cache',
                            caption: 'Redownload game content on next launch',
                            icon: Icons.delete_sweep_outlined,
                            onConfirm: _clearCache,
                          ),
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// _AdultModeCard — warning-style 18+ toggle card
// ─────────────────────────────────────────────────────────────────────────────

class _AdultModeCard extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _AdultModeCard({
    required this.enabled,
    required this.onToggle,
  });

  @override
  State<_AdultModeCard> createState() => _AdultModeCardState();
}

class _AdultModeCardState extends State<_AdultModeCard> {
  bool _pressing = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressing = true);
  void _onTapUp(TapUpDetails _) {
    setState(() => _pressing = false);
    widget.onToggle(!widget.enabled);
  }

  void _onTapCancel() => setState(() => _pressing = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressing ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.enabled
                ? const Color(0xFFFFF5F7)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.enabled
                  ? const Color(0xFFFFD6DD)
                  : const Color(0x18000000),
              width: widget.enabled ? 1.5 : 1.0,
            ),
            boxShadow: widget.enabled
                ? [
                    const BoxShadow(
                      color: Color(0x20E8436A),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Left content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Adult Mode',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: widget.enabled
                                ? const Color(0xFFE8436A)
                                : const Color(0xFF2D1B4E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (widget.enabled) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '⚠️',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Includes 18+ challenges',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: widget.enabled
                            ? const Color(0xFFE8436A).withValues(alpha: 0.7)
                            : const Color(0xFF2D1B4E).withValues(alpha: 0.5),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Custom switch
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? const Color(0xFFE8436A)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: widget.enabled
                      ? [
                          const BoxShadow(
                            color: Color(0x30E8436A),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  alignment: widget.enabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
