import 'package:flutter/material.dart';

class Attendance {
  final String id;
  final String userId;
  final DateTime date;
  final String time;
  final String subject;
  final int period;
  final String status;
  final double? latitude;
  final double? longitude;
  final double? distanceFromCampus;
  final String? wifiSSID;
  final String verificationMethod;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.subject,
    required this.period,
    required this.status,
    this.latitude,
    this.longitude,
    this.distanceFromCampus,
    this.wifiSSID,
    required this.verificationMethod,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
      period: json['period'] ?? 1,
      status: json['status'] ?? 'absent',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distanceFromCampus: json['distance_from_campus']?.toDouble(),
      wifiSSID: json['wifi_ssid'],
      verificationMethod: json['verification_method'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'time': time,
      'subject': subject,
      'period': period,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'distance_from_campus': distanceFromCampus,
      'wifi_ssid': wifiSSID,
      'verification_method': verificationMethod,
    };
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'present':
        return Color(0xFF4CAF50);
      case 'late':
        return Color(0xFFFFC107);
      case 'absent':
        return Color(0xFFE91E63);
      default:
        return Color(0xFF9E9E9E);
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.access_time;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}