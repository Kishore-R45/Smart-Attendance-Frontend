import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/wifi_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final WiFiService _wifiService = WiFiService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    await _storage.init();
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      String? token = await _storage.getToken();
      if (token != null) {
        User? user = await _storage.getUser();
        if (user != null) {
          _user = user;
          _isLoggedIn = true;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Auth check error: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get device info
      DeviceInfo deviceInfo = await _wifiService.getDeviceInfo();

      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'device_id': deviceInfo.deviceId,
        'device_info': deviceInfo.toJson(),
      };

      final response = await _api.post('/auth/login', body, requireAuth: false);

      if (response['success'] == true) {
        // Save token
        await _storage.saveToken(response['data']['token']);

        // Save user
        _user = User.fromJson(response['data']['user']);
        await _storage.saveUser(_user!);

        // Save device ID
        await _storage.saveDeviceId(deviceInfo.deviceId);

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String studentId,
    required String name,
    required String email,
    required String password,
    required String department,
    required String year,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get device info
      DeviceInfo deviceInfo = await _wifiService.getDeviceInfo();

      Map<String, dynamic> body = {
        'student_id': studentId,
        'name': name,
        'email': email,
        'password': password,
        'department': department,
        'year': year,
        'phone': phone,
        'device_id': deviceInfo.deviceId,
        'device_info': deviceInfo.toJson(),
      };

      final response = await _api.post('/auth/register', body, requireAuth: false);

      if (response['success'] == true) {
        // Auto login after registration
        await _storage.saveToken(response['data']['token']);
        
        _user = User.fromJson(response['data']['user']);
        await _storage.saveUser(_user!);
        await _storage.saveDeviceId(deviceInfo.deviceId);

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _storage.clearUserSession();
    _user = null;
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _api.put('/auth/profile', updates);

      if (response['success'] == true) {
        _user = User.fromJson(response['data']);
        await _storage.saveUser(_user!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}