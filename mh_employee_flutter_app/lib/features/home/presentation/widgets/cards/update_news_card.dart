import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_decorations.dart';
import '../../../../../core/widgets/cards/modern_card.dart';
import '../../../../../shared/models/news_item.dart';

/// Modern Update News Card with Glassmorphic Design
class UpdateNewsCard extends StatelessWidget {
  final NewsItem item;
  final String? currentUserName;
  final VoidCallback onTap;

  const UpdateNewsCard({
    Key? key,
    required this.item,
    this.currentUserName,
    required this.onTap,
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
            if (!item.isRead && item.author != (currentUserName ?? ''))
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: _getCategoryGradient(),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: AppDecorations.shadowSm,
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.lg),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Content
                      Text(
                        item.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Author
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.displayName ?? item.author,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(item.datePosted),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getCategoryGradient() {
    if (item.title.toLowerCase().contains('event')) {
      return AppDecorations.accentGradient;
    } else if (item.title.toLowerCase().contains('update')) {
      return AppDecorations.primaryGradient;
    } else if (item.title.toLowerCase().contains('announcement')) {
      return AppDecorations.secondaryGradient;
    }
    return AppDecorations.primaryGradient;
  }

  IconData _getCategoryIcon() {
    if (item.title.toLowerCase().contains('event')) {
      return Icons.event_note;
    } else if (item.title.toLowerCase().contains('update')) {
      return Icons.update;
    } else if (item.title.toLowerCase().contains('announcement')) {
      return Icons.campaign;
    }
    return Icons.article;
  }
}
