import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_provider.dart';
import 'game_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  static const routeName = '/player-setup';

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addPlayer() {
    if (_controllers.length >= 10) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removePlayer(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  Future<void> _startGame() async {
    final players = _controllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least 2 player names')),
      );
      return;
    }

    final provider = context.read<GameProvider>();
    await provider.startGame(players);

    if (!mounted) return;

    if (provider.state == GameState.playing) {
      Navigator.pushReplacementNamed(context, GameScreen.routeName);
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<GameProvider>().state == GameState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _controllers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Player ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      if (_controllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removePlayer(index),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (_controllers.length < 10)
              TextButton.icon(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add),
                label: const Text('Add Player'),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _startGame,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Start Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
