import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_model.dart';

class CalendarView extends StatelessWidget {
  final List<Attendance> attendanceList;
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime, List<Attendance>) onDayTapped;

  const CalendarView({
    Key? key,
    required this.attendanceList,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.onDayTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month selector
        Container(
          padding: EdgeInsets.all(15),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  onMonthChanged(
                    DateTime(selectedMonth.year, selectedMonth.month - 1),
                  );
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  onMonthChanged(
                    DateTime(selectedMonth.year, selectedMonth.month + 1),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Calendar grid
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildCalendarGrid(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;

    return GridView.builder(
      padding: EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: 42, // 6 weeks × 7 days
      itemBuilder: (context, index) {
        // Day headers
        if (index < 7) {
          return _buildDayHeader(index);
        }

        // Calculate day number
        final dayIndex = index - 7 - startWeekday + 2;
        
        if (dayIndex < 1 || dayIndex > daysInMonth) {
          return Container(); // Empty cell
        }

        final date = DateTime(selectedMonth.year, selectedMonth.month, dayIndex);
        final dayAttendance = _getAttendanceForDay(date);

        return _buildDayCell(context, date, dayAttendance);
      },
    );
  }

  Widget _buildDayHeader(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Center(
      child: Text(
        days[index],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, List<Attendance> attendance) {
    final isToday = _isSameDay(date, DateTime.now());
    final hasAttendance = attendance.isNotEmpty;
    
    Color? backgroundColor;
    Color? borderColor;
    
    if (hasAttendance) {
      final allPresent = attendance.every((a) => a.status == 'present');
      final anyAbsent = attendance.any((a) => a.status == 'absent');
      
      if (allPresent) {
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (anyAbsent) {
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      } else {
        backgroundColor = Colors.orange.withOpacity(0.2);
        borderColor = Colors.orange;
      }
    }

    return InkWell(
      onTap: () => onDayTapped(date, attendance),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday
                ? Theme.of(context).primaryColor
                : borderColor ?? Colors.grey[300]!,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
            if (hasAttendance)
              Container(
                margin: EdgeInsets.only(top: 2),
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Attendance> _getAttendanceForDay(DateTime date) {
    return attendanceList.where((a) => _isSameDay(a.date, date)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}