import 'package:flutter/material.dart';

class AttendanceStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AttendanceStatsCard({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = stats['percentage'] ?? 0;
    final percentageColor = _getPercentageColor(percentage);

    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percentage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Text(
            'Overall Attendance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Present',
                stats['present']?.toString() ?? '0',
                Icons.check_circle,
              ),
              _buildStatItem(
                'Absent',
                stats['absent']?.toString() ?? '0',
                Icons.cancel,
              ),
              _buildStatItem(
                'Late',
                stats['late']?.toString() ?? '0',
                Icons.access_time,
              ),
              _buildStatItem(
                'Total',
                stats['total']?.toString() ?? '0',
                Icons.event,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getPercentageColor(dynamic percentage) {
    final value = percentage is String 
        ? double.tryParse(percentage) ?? 0.0 
        : percentage.toDouble();
    
    if (value >= 75) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }
}