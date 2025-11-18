import 'dart:io';

class DeviceModel {
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final String platform;
  final String? macAddress;
  final DateTime registeredAt;

  DeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.platform,
    this.macAddress,
    required this.registeredAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? '',
      deviceModel: json['device_model'] ?? '',
      platform: json['platform'] ?? '',
      macAddress: json['mac_address'],
      registeredAt: DateTime.parse(json['registered_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_model': deviceModel,
      'platform': platform,
      'mac_address': macAddress,
    };
  }

  static String getCurrentPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}