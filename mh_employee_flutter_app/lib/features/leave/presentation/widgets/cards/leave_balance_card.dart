import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_decorations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/modern_card.dart';

/// Modern Leave Balance Card with Enhanced Progress Ring and Glow
class LeaveBalanceCard extends StatelessWidget {
  final String leaveType;
  final int totalDays;
  final int usedDays;
  final int remainingDays;
  final Color? color;
  final IconData? icon;

  const LeaveBalanceCard({
    Key? key,
    required this.leaveType,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalDays > 0 ? remainingDays / totalDays : 0.0;
    final gradientColor = color ?? AppColors.darkPrimary;

    return ModernCard(
      variant: ModernCardVariant.glass,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Progress Ring with Glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Colored glow effect
                BoxShadow(
                  color: gradientColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
                // Progress Circle with Gradient Effect
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(gradientColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center Icon and Text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon ?? Icons.event_available,
                      color: gradientColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remainingDays',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Leave Type
          Text(
            leaveType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                context,
                'Total',
                '$totalDays',
                Theme.of(context).textTheme.bodySmall?.color,
              ),
              Container(
                width: 1,
                height: 20,
                color: Theme.of(context).dividerColor,
              ),
              _buildStat(
                context,
                'Used',
                '$usedDays',
                Colors.orange,
              ),
              Container(
                width: 1,
                height: 20,
                color: Theme.of(context).dividerColor,
              ),
              _buildStat(
                context,
                'Left',
                '$remainingDays',
                gradientColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, Color? color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
