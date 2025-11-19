class AppConfig {
  // API Configuration - Change this to your backend URL
  static const String baseUrl = 'https://smart-attendance-backend1.onrender.com/api';
  // For production: 'https://your-backend.onrender.com/api'
  
  // Campus Configuration
  static const double campusLatitude = 13.032672;
  static const double campusLongitude = 80.179273;
  static const double campusRadius = 200.0;
  
  // WiFi Configuration
  static const String campusWifiSSID = 'EEC';
  static const List<String> allowedSSIDs = ['EEC LIBRARY','CIVIL GALLERY HALL','Easwari Eng Collage','Easwari Eng College'];
  
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
    1: '08:15 AM - 9:05 AM',
    2: '09:05 AM - 09:55 AM',
    3: '10:10 AM - 11:00 AM',
    4: '11:00 AM - 11:50 AM',
    5: '11:50 AM - 12:40 PM',
    6: '01:30 PM - 02:15 PM',
    7: '02:15 PM - 03:00 PM',
    8: '03:00 PM - 03:45 PM',
  };
  
  static const List<String> subjects = [
    'DSA',
    'DBMS',
    'OS',
    'Aptitude',
    'AIML',
    'OOP in Java',
    'Ethical Hacking',
    'DCN',
  ];
}