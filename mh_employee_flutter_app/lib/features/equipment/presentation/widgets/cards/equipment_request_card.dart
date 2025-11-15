import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_decorations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/modern_card.dart';

/// Modern Equipment Request Card with Enhanced Gradients and Glow
class EquipmentRequestCard extends StatelessWidget {
  final String itemName;
  final String category;
  final int quantity;
  final String status;
  final DateTime requestDate;
  final String? remarks;
  final VoidCallback? onTap;

  const EquipmentRequestCard({
    Key? key,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.status,
    required this.requestDate,
    this.remarks,
    this.onTap,
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
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with Glow Effect
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: _getCategoryGradient(),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  // Colored glow effect
                  BoxShadow(
                    color: _getCategoryColor().withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  // Depth shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.lg),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Category and Quantity
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.numbers,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Qty: $quantity',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),

                  if (remarks != null && remarks!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      remarks!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(requestDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),

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

  IconData _getCategoryIcon() {
    final cat = category.toLowerCase();
    if (cat.contains('computer') || cat.contains('laptop')) {
      return Icons.computer;
    } else if (cat.contains('phone') || cat.contains('mobile')) {
      return Icons.phone_android;
    } else if (cat.contains('furniture')) {
      return Icons.chair;
    } else if (cat.contains('stationery')) {
      return Icons.edit;
    }
    return Icons.inventory_2;
  }

  LinearGradient _getCategoryGradient() {
    final cat = category.toLowerCase();
    if (cat.contains('computer') || cat.contains('laptop')) {
      return AppDecorations.modernBlueGradient; // Electric blue
    } else if (cat.contains('phone') || cat.contains('mobile')) {
      return AppDecorations.modernPurpleGradient; // Modern purple
    } else if (cat.contains('furniture')) {
      return AppDecorations.modernOrangeGradient; // Vibrant orange
    } else if (cat.contains('stationery')) {
      return AppDecorations.modernGreenGradient; // Fresh green
    }
    return AppDecorations.modernVioletGradient; // Violet for others
  }

  Color _getCategoryColor() {
    final cat = category.toLowerCase();
    if (cat.contains('computer') || cat.contains('laptop')) {
      return AppColors.modernGradient2.first; // Blue
    } else if (cat.contains('phone') || cat.contains('mobile')) {
      return AppColors.modernGradient1.first; // Purple
    } else if (cat.contains('furniture')) {
      return AppColors.modernGradient5.first; // Orange
    } else if (cat.contains('stationery')) {
      return AppColors.modernGradient4.first; // Green
    }
    return AppColors.modernGradient6.first; // Violet
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.neonGreen; // Vibrant neon green
      case 'pending':
        return const Color(0xFFFFB74D);
      case 'rejected':
        return AppColors.modernGradient3.first; // Modern pink/red
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
