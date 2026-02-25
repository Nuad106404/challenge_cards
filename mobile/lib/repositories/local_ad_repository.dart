import '../core/services/api_service.dart';
import '../models/local_ad_model.dart';

class LocalAdRepository {
  LocalAdRepository._();
  static final LocalAdRepository instance = LocalAdRepository._();

  final _api = ApiService.instance;

  Future<List<LocalAdModel>> fetchActiveAds() async {
    final data = await _api.get('/public/local-ads');
    final list = data as List<dynamic>;
    return list
        .map((e) => LocalAdModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
