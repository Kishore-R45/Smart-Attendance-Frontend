import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
  }

  // User Management
  Future<void> saveUser(User user) async {
    String userData = json.encode(user.toJson());
    await _secureStorage.write(key: AppConfig.userKey, value: userData);
  }

  Future<User?> getUser() async {
    String? userData = await _secureStorage.read(key: AppConfig.userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  // Device ID Management
  Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: AppConfig.deviceIdKey, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    return await _secureStorage.read(key: AppConfig.deviceIdKey);
  }

  // Preferences
  Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(AppConfig.themeKey, mode);
  }

  String getThemeMode() {
    return _prefs?.getString(AppConfig.themeKey) ?? 'light';
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  Future<void> clearUserSession() async {
    await deleteToken();
    await deleteUser();
  }
}