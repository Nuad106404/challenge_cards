import 'package:flutter/foundation.dart';
import '../../core/utils/game_controller.dart';
import '../../core/services/cache_service.dart';
import '../../models/game_mode_model.dart';

enum GameState { idle, loading, playing, error }

class GameProvider extends ChangeNotifier {
  GameModeModel? _selectedMode;
  late bool _include18Plus;
  GameSession? _session;
  GameState _state = GameState.idle;
  String? _error;

  GameProvider() : _include18Plus = CacheService.instance.getInclude18Plus();

  GameModeModel? get selectedMode => _selectedMode;
  bool get include18Plus => _include18Plus;
  GameSession? get session => _session;
  GameState get state => _state;
  String? get error => _error;

  String get locale => CacheService.instance.getLocale();

  void notifyLocaleChanged() => notifyListeners();

  void setMode(GameModeModel mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  Future<void> setInclude18Plus(bool value) async {
    _include18Plus = value;
    await CacheService.instance.setInclude18Plus(value);
    notifyListeners();
  }

  Future<void> startGame(List<String> players) async {
    if (_selectedMode == null) return;
    _state = GameState.loading;
    _error = null;
    notifyListeners();

    try {
      _session = await GameController.instance.createSession(
        players: players,
        modeSlug: _selectedMode!.slug,
        include18Plus: _include18Plus,
      );
      _state = GameState.playing;
    } catch (e) {
      _error = e.toString();
      _state = GameState.error;
    }
    notifyListeners();
  }

  void next() {
    if (_session == null) return;
    if (_session!.isFinished) {
      // Last card reached — reshuffle and restart from card 1.
      _session!.reshuffle();
    } else {
      _session!.next();
    }
    notifyListeners();
  }

  void previous() {
    _session?.goBack();
    notifyListeners();
  }

  bool get hasPrevious => _session?.hasPrevious ?? false;

  void endGame() {
    _session = null;
    _state = GameState.idle;
    notifyListeners();
  }

}
