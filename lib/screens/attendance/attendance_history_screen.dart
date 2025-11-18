import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../config/app_config.dart';
import '../../widgets/attendance/attendance_card.dart';
import '../../widgets/attendance/attendance_stats_card.dart';
import '../../widgets/attendance/calendar_view.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  String _filterStatus = 'all';
  String _filterSubject = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    await provider.fetchAttendanceHistory(
      month: _selectedMonth.month.toString(),
      year: _selectedMonth.year.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Stats Overview
          Consumer<AttendanceProvider>(
            builder: (context, provider, _) {
              return AttendanceStatsCard(stats: provider.stats);
            },
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: 'List View'),
                Tab(text: 'Calendar'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(),
                _buildCalendarView(),
                _buildAnalyticsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.attendanceHistory.isEmpty) {
          return _buildEmptyState();
        }

        List<Attendance> filteredList = _filterAttendance(provider.attendanceHistory);

        return Column(
          children: [
            // Filters
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterChip('All', 'all'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterChip('Present', 'present'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterChip('Absent', 'absent'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterChip('Late', 'late'),
                  ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAttendance,
                child: ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return AttendanceCard(
                      attendance: filteredList[index],
                      onTap: () => _showAttendanceDetails(filteredList[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        return CalendarView(
          attendanceList: provider.attendanceHistory,
          selectedMonth: _selectedMonth,
          onMonthChanged: (month) {
            setState(() => _selectedMonth = month);
            _loadAttendance();
          },
          onDayTapped: (date, attendance) {
            if (attendance.isNotEmpty) {
              _showDayAttendance(date, attendance);
            }
          },
        );
      },
    );
  }

  Widget _buildAnalyticsView() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Overview
              _buildMonthlyOverviewCard(provider),
              
              SizedBox(height: 20),
              
              // Subject-wise Attendance
              _buildSubjectWiseCard(provider),
              
              SizedBox(height: 20),
              
              // Attendance Trends
              _buildTrendsCard(provider),
              
              SizedBox(height: 20),
              
              // Location Heatmap
              _buildLocationHeatmap(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _filterStatus == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20),
          Text(
            'No Attendance Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your attendance history will appear here',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewCard(AttendanceProvider provider) {
    final stats = provider.stats;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Classes',
                  stats['total']?.toString() ?? '0',
                  Colors.blue,
                ),
                _buildStatItem(
                  'Present',
                  stats['present']?.toString() ?? '0',
                  Colors.green,
                ),
                _buildStatItem(
                  'Absent',
                  stats['absent']?.toString() ?? '0',
                  Colors.red,
                ),
                _buildStatItem(
                  'Percentage',
                  '${stats['percentage'] ?? 0}%',
                  Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectWiseCard(AttendanceProvider provider) {
    Map<String, Map<String, int>> subjectStats = {};
    
    for (var attendance in provider.attendanceHistory) {
      if (!subjectStats.containsKey(attendance.subject)) {
        subjectStats[attendance.subject] = {
          'present': 0,
          'absent': 0,
          'late': 0,
        };
      }
      subjectStats[attendance.subject]![attendance.status];
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject-wise Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            ...subjectStats.entries.map((entry) {
              final total = entry.value.values.reduce((a, b) => a + b);
              final presentCount = entry.value['present'] ?? 0;
              final percentage = total > 0 ? (presentCount / total * 100) : 0;
              
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: percentage >= 75 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 75 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsCard(AttendanceProvider provider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 200,
              child: Center(
                child: Text(
                  'Graph View Coming Soon',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeatmap(AttendanceProvider provider) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Attendance Locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 250,
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(
                  AppConfig.campusLatitude,
                  AppConfig.campusLongitude,
                ),
                zoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(
                        AppConfig.campusLatitude,
                        AppConfig.campusLongitude,
                      ),
                      radius: AppConfig.campusRadius,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: provider.attendanceHistory
                      .where((a) => a.latitude != null && a.longitude != null)
                      .map((a) => Marker(
                            width: 30.0,
                            height: 30.0,
                            point: LatLng(a.latitude!, a.longitude!),
                            child: Container(
                              decoration: BoxDecoration(
                                color: a.statusColor.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Attendance> _filterAttendance(List<Attendance> list) {
    if (_filterStatus == 'all') return list;
    return list.where((a) => a.status == _filterStatus).toList();
  }

  void _showAttendanceDetails(Attendance attendance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  attendance.statusIcon,
                  color: attendance.statusColor,
                  size: 40,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attendance.subject,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(attendance.date),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow('Status', attendance.status.toUpperCase()),
            _buildDetailRow('Period', 'Period ${attendance.period}'),
            _buildDetailRow('Time', attendance.time),
            _buildDetailRow(
              'Distance from Campus',
              '${attendance.distanceFromCampus?.toStringAsFixed(0) ?? 'N/A'} meters',
            ),
            _buildDetailRow('WiFi SSID', attendance.wifiSSID ?? 'N/A'),
            _buildDetailRow('Verification', attendance.verificationMethod),
            SizedBox(height: 20),
            if (attendance.latitude != null && attendance.longitude != null)
              Container(
                height: 150,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(attendance.latitude!, attendance.longitude!),
                    zoom: 17.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: LatLng(attendance.latitude!, attendance.longitude!),
                          child: Icon(
                            Icons.location_pin,
                            color: attendance.statusColor,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showDayAttendance(DateTime date, List<Attendance> attendance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('EEEE, MMM d').format(date),
          style: TextStyle(fontSize: 18),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: attendance.length,
            itemBuilder: (context, index) {
              final item = attendance[index];
              return ListTile(
                leading: Icon(
                  item.statusIcon,
                  color: item.statusColor,
                ),
                title: Text(item.subject),
                subtitle: Text('Period ${item.period} - ${item.time}'),
                trailing: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    color: item.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}