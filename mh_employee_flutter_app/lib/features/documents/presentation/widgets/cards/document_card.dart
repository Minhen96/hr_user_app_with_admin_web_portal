import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_decorations.dart';
import '../../../../../core/widgets/cards/modern_card.dart';

/// Modern Document Card with Glassmorphic Design
class DocumentCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final DateTime datePosted;
  final String type;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const DocumentCard({
    Key? key,
    required this.title,
    required this.content,
    required this.author,
    required this.datePosted,
    required this.type,
    required this.isRead,
    required this.onTap,
    this.onDownload,
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
        child: Stack(
          children: [
            // Unread indicator
            if (!isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon with Glow Effect
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _getTypeGradient(),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: [
                      // Colored glow effect
                      BoxShadow(
                        color: _getTypeColor().withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      // Subtle shadow for depth
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
                      _getTypeIcon(),
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
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Content Preview
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Footer
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            author,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(datePosted),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Download button
                if (onDownload != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: onDownload,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (type.toUpperCase()) {
      case 'MEMO':
        return Icons.article;
      case 'POLICY':
        return Icons.policy;
      case 'SOP':
        return Icons.description;
      case 'UPDATES':
        return Icons.update;
      case 'HANDBOOK':
        return Icons.menu_book;
      default:
        return Icons.insert_drive_file;
    }
  }

  LinearGradient _getTypeGradient() {
    switch (type.toUpperCase()) {
      case 'MEMO':
        return AppDecorations.modernGreenGradient; // Fresh green
      case 'POLICY':
        return AppDecorations.modernBlueGradient; // Cool blue
      case 'SOP':
        return AppDecorations.modernOrangeGradient; // Vibrant orange
      case 'UPDATES':
        return AppDecorations.modernPurpleGradient; // Modern purple
      case 'HANDBOOK':
        return AppDecorations.modernVioletGradient; // Violet
      default:
        return AppDecorations.primaryGradient;
    }
  }

  Color _getTypeColor() {
    switch (type.toUpperCase()) {
      case 'MEMO':
        return const Color(0xFF38EF7D); // Neon green
      case 'POLICY':
        return const Color(0xFF00D4FF); // Electric blue
      case 'SOP':
        return const Color(0xFFFF9A56); // Vibrant orange
      case 'UPDATES':
        return const Color(0xFF667EEA); // Modern purple
      case 'HANDBOOK':
        return const Color(0xFF4568DC); // Violet
      default:
        return const Color(0xFF00E676);
    }
  }
}
