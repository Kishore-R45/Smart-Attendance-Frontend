import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      String? token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else if (response.statusCode == 401) {
      await _storage.clearAll();
      throw AuthException('Session expired. Please login again.');
    } else {
      Map<String, dynamic> error;
      try {
        error = json.decode(response.body);
      } catch (_) {
        error = {'message': 'Server error occurred'};
      }
      throw ApiException(
        error['message'] ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? params, bool requireAuth = true}) async {
    try {
      Uri uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      if (params != null) {
        uri = uri.replace(queryParameters: params);
      }

      final response = await http.get(
        uri,
        headers: await _getHeaders(requireAuth: requireAuth),
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException || e is AuthException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {bool requireAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(requireAuth: requireAuth),
        body: json.encode(body),
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException || e is AuthException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException || e is AuthException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException || e is AuthException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}