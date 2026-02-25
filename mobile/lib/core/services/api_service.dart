import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Bootstrap URL from .env — used until the remote config is loaded.
  static String get _envBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3001/api';

  // Overridden at runtime by ConfigService once the remote config is fetched.
  String? _remoteBaseUrl;

  /// Called by ConfigService after a successful config fetch.
  void updateBaseUrl(String url) {
    if (url.isNotEmpty) _remoteBaseUrl = url;
  }

  String get _baseUrl => _remoteBaseUrl ?? _envBaseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParams,
    );
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    String message = 'Request failed';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = body['message'];
      message = raw is List ? raw.join(', ') : raw?.toString() ?? message;
    } catch (_) {}
    throw ApiException(statusCode: response.statusCode, message: message);
  }
}
