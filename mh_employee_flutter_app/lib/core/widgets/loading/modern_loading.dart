import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_animations.dart';

/// Modern Loading Indicators
class ModernLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ModernLoading({
    Key? key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.darkPrimary,
          ),
        ),
      ),
    );
  }
}

/// Skeleton Loading (Shimmer effect)
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double? borderRadius;
  final ShapeDecoration? decoration;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.decoration,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.shimmer,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: widget.decoration ??
              BoxDecoration(
                borderRadius:
                    BorderRadius.circular(widget.borderRadius ?? AppSpacing.radiusSm),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.darkSurfaceVariant,
                    AppColors.darkSurface,
                    AppColors.darkSurfaceVariant,
                  ],
                  stops: [
                    _animation.value - 0.3,
                    _animation.value,
                    _animation.value + 0.3,
                  ],
                ),
              ),
        );
      },
    );
  }
}

/// Card Skeleton Loader
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 48,
                height: 48,
                borderRadius: AppSpacing.radiusMd,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SkeletonLoader(
                      width: 150,
                      height: 12,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SkeletonLoader(
            width: double.infinity,
            height: 12,
            borderRadius: AppSpacing.radiusSm,
          ),
          const SizedBox(height: AppSpacing.sm),
          SkeletonLoader(
            width: 200,
            height: 12,
            borderRadius: AppSpacing.radiusSm,
          ),
        ],
      ),
    );
  }
}

/// List Skeleton Loader
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      padding: const EdgeInsets.all(AppSpacing.lg),
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => const CardSkeleton(),
    );
  }
}

/// Overlay Loading (Full screen)
class OverlayLoading extends StatelessWidget {
  final String? message;

  const OverlayLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ModernLoading(size: 48),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message!,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
