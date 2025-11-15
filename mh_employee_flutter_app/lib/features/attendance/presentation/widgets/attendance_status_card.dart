import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/modern_card.dart';

/// Modern Attendance Status Card with Enhanced Gradients
class AttendanceStatusCard extends StatelessWidget {
  final DateTime date;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? location;

  const AttendanceStatusCard({
    Key? key,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: ModernCard(
        variant: ModernCardVariant.glass,
        child: Row(
          children: [
            // Date Circle with Glow
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: _getStatusGradient(),
                shape: BoxShape.circle,
                boxShadow: [
                  // Colored glow
                  BoxShadow(
                    color: _getStatusColor().withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                  // Depth shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.lg),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Times
                  if (checkInTime != null)
                    Row(
                      children: [
                        Icon(
                          Icons.login,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'In: $checkInTime',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),

                  if (checkOutTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Out: $checkOutTime',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (status.toLowerCase()) {
      case 'present':
        return AppDecorations.modernGreenGradient; // Fresh green
      case 'late':
        return AppDecorations.modernOrangeGradient; // Vibrant orange
      case 'absent':
        return AppDecorations.modernPinkGradient; // Modern pink/red
      default:
        return AppDecorations.primaryGradient;
    }
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.neonGreen; // Vibrant neon green
      case 'late':
        return AppColors.modernGradient5.first; // Orange
      case 'absent':
        return AppColors.modernGradient3.first; // Pink/red
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
