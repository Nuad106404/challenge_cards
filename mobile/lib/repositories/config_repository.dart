import '../core/services/api_service.dart';
import '../models/config_model.dart';

class ConfigRepository {
  ConfigRepository._();
  static final ConfigRepository instance = ConfigRepository._();

  final _api = ApiService.instance;

  Future<ConfigModel> fetchConfig() async {
    final data = await _api.get('/public/config');
    return ConfigModel.fromJson(data as Map<String, dynamic>);
  }
}
