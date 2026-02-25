import '../core/services/api_service.dart';
import '../models/game_mode_model.dart';

class ModeRepository {
  ModeRepository._();
  static final ModeRepository instance = ModeRepository._();

  final _api = ApiService.instance;

  List<GameModeModel>? _cached;

  Future<List<GameModeModel>> getModes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;
    final data = await _api.get('/public/modes') as List<dynamic>;
    _cached = GameModeModel.listFromJson(data);
    return _cached!;
  }
}
