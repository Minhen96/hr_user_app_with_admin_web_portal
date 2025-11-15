import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

/// Modern Card Widget with multiple variants
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final ModernCardVariant variant;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.variant = ModernCardVariant.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = _getDecoration();
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);

    Widget card = Container(
      padding: effectivePadding,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          child: card,
        ),
      );
    }

    return card;
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case ModernCardVariant.standard:
        return BoxDecoration(
          color: color ?? AppColors.darkCard,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          boxShadow: boxShadow ?? AppDecorations.shadowMd,
          border: border,
        );

      case ModernCardVariant.elevated:
        return BoxDecoration(
          color: color ?? AppColors.darkSurface,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          boxShadow: boxShadow ?? AppDecorations.shadowLg,
          border: border,
        );

      case ModernCardVariant.glass:
        return BoxDecoration(
          color: (color ?? AppColors.darkSurface).withOpacity(0.7),
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          border: border ??
              Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
          boxShadow: boxShadow ?? AppDecorations.shadowMd,
        );

      case ModernCardVariant.gradient:
        return BoxDecoration(
          gradient: gradient ?? AppDecorations.primaryGradient,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          boxShadow: boxShadow ?? AppDecorations.shadowMd,
          border: border,
        );

      case ModernCardVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          border: border ??
              Border.all(
                color: AppColors.darkBorder,
                width: 1.5,
              ),
        );
    }
  }
}

enum ModernCardVariant {
  standard,
  elevated,
  glass,
  gradient,
  outlined,
}

/// Glassmorphic Card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? borderRadius;
  final double blur;
  final double opacity;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.blur = 10,
    this.opacity = 0.7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: AppDecorations.shadowMd,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Stat Card for displaying metrics
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Gradient? gradient;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.gradient,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      variant: gradient != null
          ? ModernCardVariant.gradient
          : ModernCardVariant.glass,
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.darkPrimary).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.darkPrimary,
                  size: AppSpacing.iconMd,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.darkTextSecondary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: gradient != null
                  ? Colors.white.withOpacity(0.8)
                  : AppColors.darkTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: gradient != null ? Colors.white : AppColors.darkTextPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: gradient != null
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.darkTextHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
