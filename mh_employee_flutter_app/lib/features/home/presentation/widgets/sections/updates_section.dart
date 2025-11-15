import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/loading/modern_loading.dart';
import '../../../../../core/widgets/states/empty_state.dart';
import '../../../../../shared/models/news_item.dart';
import '../cards/update_news_card.dart';

/// Modern Updates Section with Loading and Empty States
class UpdatesSection extends StatelessWidget {
  final List<NewsItem> updates;
  final bool isLoading;
  final bool isLoadingMore;
  final int unreadCount;
  final ScrollController scrollController;
  final VoidCallback onAdd;
  final VoidCallback onHistory;
  final Function(NewsItem) onUpdateTap;

  const UpdatesSection({
    Key? key,
    required this.updates,
    required this.isLoading,
    required this.isLoadingMore,
    required this.unreadCount,
    required this.scrollController,
    required this.onAdd,
    required this.onHistory,
    required this.onUpdateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildHeader(context),

        const SizedBox(height: AppSpacing.lg),

        // Content
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.massive),
            child: ModernLoading(),
          )
        else if (updates.isEmpty)
          const EmptyState(
            icon: Icons.article_outlined,
            title: 'No Updates Yet',
            message: 'Be the first to share an update with your team!',
          )
        else
          _buildUpdatesList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                'Latest Updates',
                style: AppTextStyles.heading2.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -5,
                  right: -25,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Action buttons
          Row(
            children: [
              // Add button
              _buildActionButton(
                context,
                icon: Icons.add_circle_outline,
                onTap: onAdd,
              ),

              const SizedBox(width: AppSpacing.sm),

              // History button
              _buildActionButton(
                context,
                icon: Icons.history,
                onTap: onHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesList(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            return UpdateNewsCard(
              item: updates[index],
              onTap: () => onUpdateTap(updates[index]),
            );
          },
        ),

        // Loading more indicator
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: ModernLoading(size: 32),
          ),
      ],
    );
  }
}
