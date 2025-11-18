import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class WiFiService {
  static final WiFiService _instance = WiFiService._internal();
  factory WiFiService() => _instance;
  WiFiService._internal();

  final NetworkInfo _networkInfo = NetworkInfo();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      // Web doesn't need special permissions
      return true;
    }
    
    // Only request permissions on mobile platforms
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();
    
    return statuses.values.every((status) => status == PermissionStatus.granted);
  }

  Future<WiFiConnectionInfo> getConnectionInfo() async {
    try {
      if (!kIsWeb) {
        await requestPermissions();
      }
      
      ConnectivityResult connectivity = await _connectivity.checkConnectivity();
      bool isWifi = connectivity == ConnectivityResult.wifi;
      
      String? ssid;
      String? bssid;
      
      if (isWifi && !kIsWeb) {
        // Only try to get SSID on mobile platforms
        ssid = await _networkInfo.getWifiName();
        bssid = await _networkInfo.getWifiBSSID();
        
        // Clean SSID (remove quotes)
        if (ssid != null) {
          ssid = ssid.replaceAll('"', '').replaceAll('<', '').replaceAll('>', '');
          if (ssid == 'unknown ssid' || ssid.isEmpty) {
            ssid = null;
          }
        }
      } else if (kIsWeb) {
        // For web testing, simulate WiFi connection
        ssid = 'Web-Simulated';
      }
      
      return WiFiConnectionInfo(
        isConnected: isWifi || kIsWeb,
        ssid: ssid,
        bssid: bssid,
        isValid: kIsWeb ? true : isValidCampusWiFi(ssid),
      );
    } catch (e) {
      print('Error getting WiFi info: $e');
      return WiFiConnectionInfo(
        isConnected: false,
        isValid: false,
      );
    }
  }

  bool isValidCampusWiFi(String? ssid) {
    if (ssid == null || ssid.isEmpty) return false;
    if (kIsWeb && ssid == 'Web-Simulated') return true; // For web testing
    
    return AppConfig.allowedSSIDs.any(
      (allowed) => ssid.toLowerCase().contains(allowed.toLowerCase())
    );
  }

  Future<String?> getDeviceId() async {
    try {
      if (kIsWeb) {
        // For web, generate a unique ID based on browser info
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        return 'web_${webInfo.userAgent?.hashCode ?? 'unknown'}';
      } else {
        // For mobile platforms
        if (defaultTargetPlatform == TargetPlatform.android) {
          AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
          return androidInfo.id;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
          return iosInfo.identifierForVendor;
        }
      }
      return null;
    } catch (e) {
      print('Error getting device ID: $e');
      return 'unknown_device';
    }
  }

  Future<DeviceInfo> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        return DeviceInfo(
          deviceId: await getDeviceId() ?? 'web_unknown',
          deviceName: webInfo.browserName.name,
          deviceModel: 'Web Browser',
          manufacturer: webInfo.vendor ?? 'Unknown',
          platform: 'web',
          osVersion: webInfo.appVersion ?? 'Unknown',
        );
      } else {
        // Mobile platform code
        if (defaultTargetPlatform == TargetPlatform.android) {
          AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
          return DeviceInfo(
            deviceId: androidInfo.id,
            deviceName: androidInfo.model,
            deviceModel: androidInfo.device,
            manufacturer: androidInfo.manufacturer,
            platform: 'android',
            osVersion: androidInfo.version.release,
          );
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
          return DeviceInfo(
            deviceId: iosInfo.identifierForVendor ?? '',
            deviceName: iosInfo.name,
            deviceModel: iosInfo.model,
            manufacturer: 'Apple',
            platform: 'ios',
            osVersion: iosInfo.systemVersion,
          );
        }
      }
      
      // Fallback
      return DeviceInfo(
        deviceId: 'unknown',
        deviceName: 'Unknown Device',
        deviceModel: 'Unknown',
        manufacturer: 'Unknown',
        platform: 'unknown',
        osVersion: 'Unknown',
      );
    } catch (e) {
      print('Error getting device info: $e');
      // Return fallback device info
      return DeviceInfo(
        deviceId: 'error_device',
        deviceName: 'Unknown Device',
        deviceModel: 'Unknown',
        manufacturer: 'Unknown',
        platform: kIsWeb ? 'web' : 'mobile',
        osVersion: 'Unknown',
      );
    }
  }

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<bool> isConnectedToInternet() async {
    var connectivity = await _connectivity.checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }
}

class WiFiConnectionInfo {
  final bool isConnected;
  final String? ssid;
  final String? bssid;
  final bool isValid;

  WiFiConnectionInfo({
    required this.isConnected,
    this.ssid,
    this.bssid,
    required this.isValid,
  });
}

class DeviceInfo {
  final String deviceId;
  final String? deviceName;
  final String? deviceModel;
  final String? manufacturer;
  final String platform;
  final String? osVersion;

  DeviceInfo({
    required this.deviceId,
    this.deviceName,
    this.deviceModel,
    this.manufacturer,
    required this.platform,
    this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_model': deviceModel,
      'manufacturer': manufacturer,
      'platform': platform,
      'os_version': osVersion,
    };
  }
}