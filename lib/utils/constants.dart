import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Smart Attendance';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Geo-fence and WiFi based attendance system';
  
  // Departments
  static const List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Electrical',
    'Mechanical',
    'Civil',
    'Chemical',
    'Biotechnology',
    'Mathematics',
    'Physics',
  ];
  
  // Years
  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'PG 1st Year',
    'PG 2nd Year',
  ];
  
  // Subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Computer Science',
    'Data Structures',
    'Algorithms',
    'Database Systems',
    'Operating Systems',
    'Computer Networks',
    'Software Engineering',
    'Web Development',
    'Mobile Computing',
    'Artificial Intelligence',
    'Machine Learning',
  ];
  
  // Attendance Status
  static const Map<String, Color> statusColors = {
    'present': Colors.green,
    'absent': Colors.red,
    'late': Colors.orange,
    'holiday': Colors.blue,
    'leave': Colors.purple,
  };
  
  // Time Slots
  static const Map<int, Map<String, String>> timeSlots = {
    1: {'start': '09:00', 'end': '09:50'},
    2: {'start': '10:00', 'end': '10:50'},
    3: {'start': '11:00', 'end': '11:50'},
    4: {'start': '12:00', 'end': '12:50'},
    5: {'start': '14:00', 'end': '14:50'},
    6: {'start': '15:00', 'end': '15:50'},
    7: {'start': '16:00', 'end': '16:50'},
  };
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int phoneNumberLength = 10;
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(15);
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String locationError = 'Unable to get your location';
  static const String wifiError = 'Please connect to campus WiFi';
  static const String authError = 'Authentication failed';
  static const String sessionExpired = 'Session expired. Please login again';
  
  // Success Messages
  static const String attendanceMarked = 'Attendance marked successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String passwordChanged = 'Password changed successfully!';
}