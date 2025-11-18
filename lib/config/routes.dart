import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/attendance/mark_attendance_screen.dart';
import '../screens/attendance/attendance_history_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String markAttendance = '/mark-attendance';
  static const String attendanceHistory = '/attendance-history';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => SplashScreen(),
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      home: (context) => HomeScreen(),
      dashboard: (context) => DashboardScreen(),
      markAttendance: (context) => MarkAttendanceScreen(),
      attendanceHistory: (context) => AttendanceHistoryScreen(),
      profile: (context) => ProfileScreen(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case markAttendance:
        return MaterialPageRoute(builder: (_) => MarkAttendanceScreen());
      case attendanceHistory:
        return MaterialPageRoute(builder: (_) => AttendanceHistoryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}