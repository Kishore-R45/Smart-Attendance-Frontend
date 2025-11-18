import 'package:flutter/material.dart';
import '../config/theme.dart';

class UIHelpers {
  // Status Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppTheme.successColor;
      case 'absent':
        return AppTheme.errorColor;
      case 'late':
        return AppTheme.warningColor;
      case 'leave':
        return AppTheme.infoColor;
      case 'holiday':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.textTertiary;
    }
  }

  // Status Icons
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      case 'late':
        return Icons.watch_later_rounded;
      case 'leave':
        return Icons.event_busy_rounded;
      case 'holiday':
        return Icons.celebration_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Card Decoration
  static BoxDecoration modernCardDecoration({
    Color? color,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.dividerColor,
        width: 1,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ]
          : [],
    );
  }

  // Gradient Card
  static BoxDecoration gradientCardDecoration({
    required List<Color> colors,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ]
          : [],
    );
  }

  // Shimmer Effect for Loading
  static Widget shimmerEffect({
    required double width,
    required double height,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // Empty State Widget
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}