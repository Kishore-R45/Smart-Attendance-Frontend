import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../config/theme.dart';
import 'dashboard_screen.dart';
import '../attendance/mark_attendance_screen.dart';
import '../attendance/attendance_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(),
      MarkAttendanceScreen(),
      AttendanceHistoryScreen(),
      ProfileScreen(),
    ];
    // Load data AFTER the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    await attendanceProvider.fetchAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (mounted) {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        iconSize: 20,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home_25),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.finger_cricle),
            activeIcon: Icon(Iconsax.finger_scan),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar),
            activeIcon: Icon(Iconsax.calendar_2),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            activeIcon: Icon(Iconsax.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}