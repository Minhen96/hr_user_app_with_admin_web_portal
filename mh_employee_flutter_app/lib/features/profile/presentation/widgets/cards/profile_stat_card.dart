import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/modern_card.dart';

/// Modern Profile Stat Card with Enhanced Glow
class ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  const ProfileStatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? AppColors.darkPrimary;

    return ModernCard(
      variant: ModernCardVariant.glass,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Glow Effect
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: statColor.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                // Colored glow
                BoxShadow(
                  color: statColor.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: statColor,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
