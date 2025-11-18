import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  bool _isTracking = false;
  LocationPermissionStatus? _permissionStatus;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  LocationPermissionStatus? get permissionStatus => _permissionStatus;
  String? get error => _error;
  bool get hasPermission => _permissionStatus == LocationPermissionStatus.granted;

  Future<void> checkPermission() async {
    _permissionStatus = await _locationService.checkPermission();
    notifyListeners();
  }

  Future<bool> requestPermission() async {
    _permissionStatus = await _locationService.checkPermission();
    notifyListeners();
    return hasPermission;
  }

  Future<void> getCurrentLocation() async {
    try {
      _error = null;
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        notifyListeners();
      } else {
        _error = 'Unable to get location';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void startTracking() {
    if (_isTracking) return;
    
    _isTracking = true;
    _locationService.startLocationTracking(
      onLocationUpdate: (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isTracking = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _locationService.stopLocationTracking();
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}