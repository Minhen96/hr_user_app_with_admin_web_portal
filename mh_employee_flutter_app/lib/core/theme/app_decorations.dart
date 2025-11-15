import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Modern Decoration System
/// Provides consistent decorations, shadows, and effects
class AppDecorations {
  // ========== SHADOWS ==========

  // Soft shadows for dark mode
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  // Colored shadows (for accents)
  static List<BoxShadow> shadowColored(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // Glow effect
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.5),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  // ========== GRADIENTS ==========

  // Primary gradient (green)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: AppColors.darkPrimaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient (teal)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: AppColors.darkSecondaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient (pink)
  static const LinearGradient accentGradient = LinearGradient(
    colors: AppColors.darkAccentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle dark gradient for backgrounds
  static LinearGradient get darkGradient => LinearGradient(
        colors: [
          AppColors.darkBackground,
          AppColors.darkSurface,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // Glassmorphic gradient overlay
  static LinearGradient get glassGradient => LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Shimmer gradient for loading
  static LinearGradient get shimmerGradient => LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // NEW: Modern Gradient Sets for Cool UI
  static const LinearGradient modernPurpleGradient = LinearGradient(
    colors: AppColors.modernGradient1,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient modernBlueGradient = LinearGradient(
    colors: AppColors.modernGradient2,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient modernPinkGradient = LinearGradient(
    colors: AppColors.modernGradient3,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient modernGreenGradient = LinearGradient(
    colors: AppColors.modernGradient4,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient modernOrangeGradient = LinearGradient(
    colors: AppColors.modernGradient5,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient modernVioletGradient = LinearGradient(
    colors: AppColors.modernGradient6,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== BORDERS ==========

  static BoxBorder borderAll({Color? color, double width = 1}) => Border.all(
        color: color ?? AppColors.darkBorder,
        width: width,
      );

  static BoxBorder get borderLight => Border.all(
        color: AppColors.darkBorder.withOpacity(0.5),
        width: 1,
      );

  static BoxBorder get borderAccent => Border.all(
        color: AppColors.darkPrimary,
        width: 2,
      );

  // ========== CARD DECORATIONS ==========

  // Standard card (dark mode)
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: shadowMd,
      );

  // Elevated card
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: shadowLg,
      );

  // Glassmorphic card
  static BoxDecoration get cardGlass => BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: shadowMd,
      );

  // Gradient card
  static BoxDecoration cardGradient(Gradient gradient) => BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: shadowMd,
      );

  // Card with colored border
  static BoxDecoration cardBordered(Color borderColor) => BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: shadowSm,
      );

  // ========== BUTTON DECORATIONS ==========

  // Primary button
  static BoxDecoration get buttonPrimary => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: shadowColored(AppColors.darkPrimary),
      );

  // Secondary button
  static BoxDecoration get buttonSecondary => BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.darkBorder),
      );

  // Outlined button
  static BoxDecoration buttonOutlined(Color color) => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color, width: 2),
      );

  // ========== INPUT DECORATIONS ==========

  static InputDecoration inputDecoration({
    String? label,
    String? hint,
    Widget? prefix,
    Widget? suffix,
    bool filled = true,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: filled,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.error),
        ),
      );

  // ========== SPECIAL EFFECTS ==========

  // Shimmer effect for loading
  static BoxDecoration get shimmer => BoxDecoration(
        gradient: shimmerGradient,
      );

  // Neumorphic effect (subtle for dark mode)
  static BoxDecoration get neumorphic => BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      );

  // Frosted glass blur background
  static BoxDecoration get frostedGlass => BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      );
}
