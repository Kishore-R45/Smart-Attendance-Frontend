import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/wifi_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();
  final WiFiService _wifiService = WiFiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      DeviceInfo deviceInfo = await _wifiService.getDeviceInfo();
      
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'device_id': deviceInfo.deviceId,
          'device_info': deviceInfo.toJson(),
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.saveToken(data['data']['token']);
        await _storage.saveUser(User.fromJson(data['data']['user']));
        await _storage.saveDeviceId(deviceInfo.deviceId);
        
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'token': data['data']['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      DeviceInfo deviceInfo = await _wifiService.getDeviceInfo();
      userData['device_id'] = deviceInfo.deviceId;
      userData['device_info'] = deviceInfo.toJson();

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.saveToken(data['data']['token']);
        await _storage.saveUser(User.fromJson(data['data']['user']));
        await _storage.saveDeviceId(deviceInfo.deviceId);
        
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'token': data['data']['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    await _storage.clearUserSession();
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.getToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    return await _storage.getUser();
  }

  Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      String? token = await _storage.getToken();
      
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Password update failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Password reset failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}