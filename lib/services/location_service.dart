import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamController<Position>? _locationController;
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastPosition;

  Position? get lastPosition => _lastPosition;

  Future<LocationPermissionStatus> checkPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    if (kIsWeb) {
      // Can't open app settings on web
      return false;
    }
    return await openAppSettings();
  }

  Future<Position?> getCurrentLocation({bool highAccuracy = true}) async {
    try {
      LocationPermissionStatus status = await checkPermission();
      if (status != LocationPermissionStatus.granted) {
        print('Location permission not granted: $status');
        
        // For web testing, return a simulated position
        if (kIsWeb && status == LocationPermissionStatus.serviceDisabled) {
          return Position(
            latitude: AppConfig.campusLatitude + (Random().nextDouble() - 0.5) * 0.001,
            longitude: AppConfig.campusLongitude + (Random().nextDouble() - 0.5) * 0.001,
            timestamp: DateTime.now(),
            accuracy: 10.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        }
        
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
        timeLimit: AppConfig.locationTimeout,
      );

      _lastPosition = position;

      // Check for mock location on Android (not applicable on web)
      if (!kIsWeb && (position.isMocked ?? false)) {
        throw MockLocationException('Mock location detected');
      }

      return position;
    } catch (e) {
      print('Error getting location: $e');
      
      // For web testing, return a simulated position near campus
      if (kIsWeb) {
        return Position(
          latitude: AppConfig.campusLatitude + (Random().nextDouble() - 0.5) * 0.001,
          longitude: AppConfig.campusLongitude + (Random().nextDouble() - 0.5) * 0.001,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }
      
      return null;
    }
  }

  bool isInsideGeofence(Position position, {
    double? centerLat,
    double? centerLng,
    double? radius,
  }) {
    double distance = calculateDistance(
      position.latitude,
      position.longitude,
      centerLat ?? AppConfig.campusLatitude,
      centerLng ?? AppConfig.campusLongitude,
    );
    
    return distance <= (radius ?? AppConfig.campusRadius);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  void startLocationTracking({
    required Function(Position) onLocationUpdate,
    Function(Object)? onError,
    int distanceFilter = 10,
  }) {
    if (kIsWeb) {
      print('Location tracking not fully supported on web');
      return;
    }
    
    stopLocationTracking();

    _locationController = StreamController<Position>.broadcast();
    
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (!(position.isMocked ?? false)) {
          _lastPosition = position;
          onLocationUpdate(position);
          _locationController?.add(position);
        }
      },
      onError: onError,
    );
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationController?.close();
    _locationSubscription = null;
    _locationController = null;
  }

  Stream<Position>? get locationStream => _locationController?.stream;

  void dispose() {
    stopLocationTracking();
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class MockLocationException implements Exception {
  final String message;
  MockLocationException(this.message);
  
  @override
  String toString() => message;
}