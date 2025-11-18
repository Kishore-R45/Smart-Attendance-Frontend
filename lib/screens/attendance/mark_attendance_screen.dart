import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/attendance_provider.dart';
import '../../services/location_service.dart';
import '../../services/wifi_service.dart';
import '../../config/app_config.dart';

class MarkAttendanceScreen extends StatefulWidget {
  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final LocationService _locationService = LocationService();
  final WiFiService _wifiService = WiFiService();
  
  bool _isLoading = false;
  bool _locationValid = false;
  bool _wifiValid = false;
  String _statusMessage = 'Tap to mark attendance';
  
  Position? _currentPosition;
  String? _connectedSSID;
  double? _distanceFromCampus;
  
  String _selectedSubject = 'Mathematics';
  int _selectedPeriod = 1;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRequirements();
      _initializePeriod();
    });
  }

  void _initializePeriod() {
    if (!mounted) return;
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final currentPeriod = attendanceProvider.getCurrentPeriod();
    if (mounted) {
      setState(() {
        _selectedPeriod = currentPeriod == 0 ? 1 : currentPeriod;
      });
    }
  }

  Future<void> _checkRequirements() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Check location
      Position? position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        _currentPosition = position;
        _locationValid = _locationService.isInsideGeofence(position);
        _distanceFromCampus = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          AppConfig.campusLatitude,
          AppConfig.campusLongitude,
        );
      }

      // Check WiFi
      WiFiConnectionInfo wifiInfo = await _wifiService.getConnectionInfo();
      if (mounted) {
        _connectedSSID = wifiInfo.ssid;
        _wifiValid = wifiInfo.isValid;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateStatusMessage();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error checking requirements';
        });
      }
    }
  }

  void _updateStatusMessage() {
    if (!_locationValid) {
      _statusMessage = 'You are outside campus boundary (${_distanceFromCampus?.toStringAsFixed(0)}m away)';
    } else if (!_wifiValid) {
      _statusMessage = 'Please connect to campus WiFi (Current: ${_connectedSSID ?? "None"})';
    } else {
      _statusMessage = 'Ready to mark attendance ✓';
    }
  }

  Future<void> _markAttendance() async {
    if (!_locationValid || !_wifiValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      
      await attendanceProvider.checkRequirements();
      
      bool success = await attendanceProvider.markAttendance(
        subject: _selectedSubject,
        period: _selectedPeriod,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance marked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(attendanceProvider.error ?? 'Failed to mark attendance');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: SpinKitFadingCircle(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
              )
            : SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    SizedBox(height: 20),
                    _buildRequirementsCard(),
                    SizedBox(height: 20),
                    _buildSubjectPeriodCard(),
                    SizedBox(height: 20),
                    _buildLocationCard(),
                    SizedBox(height: 20),
                    _buildWiFiCard(),
                    SizedBox(height: 30),
                    _buildMarkAttendanceButton(),
                    SizedBox(height: 20), // Add bottom padding
                  ],
                ),
              ),
      ),
    );
  }

  // Rest of your build methods remain the same...
  Widget _buildSubjectPeriodCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Class Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.book),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: AppConfig.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(
                    subject,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (mounted && value != null) {
                  setState(() {
                    _selectedSubject = value;
                  });
                }
              },
            ),
            
            SizedBox(height: 15),
            
            DropdownButtonFormField<int>(
              value: _selectedPeriod,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Period',
                prefixIcon: Icon(Icons.access_time),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: AppConfig.periods.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    'Period ${entry.key} - ${entry.value}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (mounted && value != null) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = (_locationValid && _wifiValid) 
        ? Colors.green 
        : Colors.orange;
    
    IconData statusIcon = (_locationValid && _wifiValid)
        ? Icons.check_circle
        : Icons.warning;

    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.8), statusColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: Colors.white, size: 40),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildRequirementItem(
              'Inside Campus',
              _locationValid,
              'Within ${AppConfig.campusRadius.toInt()}m radius',
            ),
            _buildRequirementItem(
              'Campus WiFi',
              _wifiValid,
              'Connected to ${AppConfig.campusWifiSSID}',
            ),
            _buildRequirementItem(
              'Device Registered',
              true,
              'Device verified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String title, bool isValid, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Location Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_currentPosition != null) ...[
              Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
              Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
              Text('Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(2)}m'),
              Text('Distance from campus: ${_distanceFromCampus?.toStringAsFixed(0)}m'),
            ] else
              Text('Location not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildWiFiCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.wifi, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'WiFi Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Connected SSID: ${_connectedSSID ?? "Not connected"}'),
            Text('Status: ${_wifiValid ? "Valid Campus WiFi ✓" : "Invalid ✗"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkAttendanceButton() {
    bool canMark = _locationValid && _wifiValid;
    
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: canMark ? _markAttendance : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canMark ? Colors.green : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 28),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'MARK ATTENDANCE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}