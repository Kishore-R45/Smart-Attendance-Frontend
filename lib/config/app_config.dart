class AppConfig {
  // API Configuration - Change this to your backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  // For production: 'https://your-backend.onrender.com/api'
  
  // Campus Configuration
  static const double campusLatitude = 13.0827;
  static const double campusLongitude = 80.2707;
  static const double campusRadius = 150.0;
  
  // WiFi Configuration
  static const String campusWifiSSID = 'Campus-WiFi';
  static const List<String> allowedSSIDs = ['Campus-WiFi', 'Campus-5G', 'Campus-Guest'];
  
  // App Configuration
  static const Duration sessionTimeout = Duration(days: 7);
  static const Duration locationTimeout = Duration(seconds: 10);
  static const int maxLoginAttempts = 3;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String deviceIdKey = 'device_id';
  static const String themeKey = 'theme_mode';
  
  // Time Configuration
  static const Map<int, String> periods = {
    1: '9:00 AM - 9:50 AM',
    2: '10:00 AM - 10:50 AM',
    3: '11:00 AM - 11:50 AM',
    4: '12:00 PM - 12:50 PM',
    5: '2:00 PM - 2:50 PM',
    6: '3:00 PM - 3:50 PM',
    7: '4:00 PM - 4:50 PM',
  };
  
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Computer Science',
    'English',
    'Biology',
    'History',
    'Geography',
  ];
}