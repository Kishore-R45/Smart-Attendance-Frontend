import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/wifi_service.dart';
import '../config/app_config.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final LocationService _locationService = LocationService();
  final WiFiService _wifiService = WiFiService();

  List<Attendance> _attendanceHistory = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;
  
  // Current attendance state
  bool _locationValid = false;
  bool _wifiValid = false;
  Position? _currentPosition;
  String? _currentSSID;
  double? _distanceFromCampus;

  List<Attendance> get attendanceHistory => _attendanceHistory;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get locationValid => _locationValid;
  bool get wifiValid => _wifiValid;
  Position? get currentPosition => _currentPosition;
  String? get currentSSID => _currentSSID;
  double? get distanceFromCampus => _distanceFromCampus;
  bool get canMarkAttendance => _locationValid && _wifiValid;

  Future<bool> checkRequirements() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check location
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        _locationValid = _locationService.isInsideGeofence(position);
        _distanceFromCampus = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          AppConfig.campusLatitude,
          AppConfig.campusLongitude,
        );
      } else {
        _locationValid = false;
        _error = 'Unable to get location';
      }

      // Check WiFi
      WiFiConnectionInfo wifiInfo = await _wifiService.getConnectionInfo();
      _currentSSID = wifiInfo.ssid;
      _wifiValid = wifiInfo.isValid;

      if (!_locationValid) {
        _error = 'You are ${_distanceFromCampus?.toStringAsFixed(0)}m away from campus';
      } else if (!_wifiValid) {
        _error = 'Please connect to campus WiFi';
      }

      _isLoading = false;
      notifyListeners();
      return canMarkAttendance;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAttendance({
    required String subject,
    required int period,
  }) async {
    try {
      if (!canMarkAttendance) {
        await checkRequirements();
        if (!canMarkAttendance) {
          return false;
        }
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      String? deviceId = await _wifiService.getDeviceId();

      Map<String, dynamic> body = {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'accuracy': _currentPosition!.accuracy,
        'ssid': _currentSSID,
        'device_id': deviceId,
        'subject': subject,
        'period': period,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _api.post('/attendance/mark', body);

      if (response['success'] == true) {
        // Refresh attendance history
        await fetchAttendanceHistory();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to mark attendance';
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

  Future<void> fetchAttendanceHistory({String? month, String? year}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Map<String, String> params = {};
      if (month != null) params['month'] = month;
      if (year != null) params['year'] = year;

      final response = await _api.get('/attendance/history', params: params);

      if (response['success'] == true) {
        _attendanceHistory = (response['data']['attendance'] as List)
            .map((json) => Attendance.fromJson(json))
            .toList();
        
        _stats = response['data']['stats'] ?? {};
        
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Failed to fetch history';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodayAttendance() async {
    try {
      final now = DateTime.now();
      await fetchAttendanceHistory(
        month: now.month.toString(),
        year: now.year.toString(),
      );
      
      // Filter for today
      _attendanceHistory = _attendanceHistory.where((a) {
        return a.date.day == now.day &&
               a.date.month == now.month &&
               a.date.year == now.year;
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  int getCurrentPeriod() {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    if (currentTime >= 540 && currentTime < 590) return 1;  // 9:00-9:50
    if (currentTime >= 600 && currentTime < 650) return 2;  // 10:00-10:50
    if (currentTime >= 660 && currentTime < 710) return 3;  // 11:00-11:50
    if (currentTime >= 720 && currentTime < 770) return 4;  // 12:00-12:50
    if (currentTime >= 840 && currentTime < 890) return 5;  // 14:00-14:50
    if (currentTime >= 900 && currentTime < 950) return 6;  // 15:00-15:50
    if (currentTime >= 960 && currentTime < 1010) return 7; // 16:00-16:50
    
    return 0; // No active period
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _locationValid = false;
    _wifiValid = false;
    _currentPosition = null;
    _currentSSID = null;
    _distanceFromCampus = null;
    _error = null;
    notifyListeners();
  }
}