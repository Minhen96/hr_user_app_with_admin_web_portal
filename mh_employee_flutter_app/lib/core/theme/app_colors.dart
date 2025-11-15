import 'package:flutter/material.dart';

class AppColors {
  // ==================== MODERN REDESIGN - LIGHT THEME ====================

  // Light Theme - Primary Colors (Modern Purple-Blue)
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400

  // Light Theme - Secondary Colors (Vibrant Teal-Cyan)
  static const Color secondary = Color(0xFF06B6D4); // Cyan-500
  static const Color secondaryDark = Color(0xFF0891B2); // Cyan-600
  static const Color secondaryLight = Color(0xFF22D3EE); // Cyan-400

  // Light Theme - Accent Colors (Vibrant Pink-Purple)
  static const Color accent = Color(0xFFEC4899); // Pink-500
  static const Color accentDark = Color(0xFFDB2777); // Pink-600
  static const Color accentLight = Color(0xFFF472B6); // Pink-400

  // Light Theme - Background Colors (Soft & Clean)
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800

  // Light Theme - Text Colors (Modern & Clear)
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textHint = Color(0xFF94A3B8); // Slate-400
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors (Modern & Vibrant)
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // Light Theme - Border Colors
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color borderDark = Color(0xFFCBD5E1); // Slate-300

  // Divider Color
  static const Color divider = Color(0xFFE2E8F0); // Slate-200

  // Disabled Color
  static const Color disabled = Color(0xFF94A3B8); // Slate-400

  // Shadow Color
  static const Color shadow = Color(0x1A000000);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);

  // Modern Gradient Colors
  static const List<Color> primaryGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)]; // Indigo to Purple
  static const List<Color> secondaryGradient = [Color(0xFF06B6D4), Color(0xFF3B82F6)]; // Cyan to Blue
  static const List<Color> accentGradient = [Color(0xFFEC4899), Color(0xFFF97316)]; // Pink to Orange

  // ==================== MODERN REDESIGN - DARK THEME ====================

  // Dark Theme - Background Colors (Deep & Rich)
  static const Color darkBackground = Color(0xFF0F172A); // Slate-900
  static const Color darkSurface = Color(0xFF1E293B); // Slate-800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate-700
  static const Color darkCard = Color(0xFF1E293B); // Slate-800

  // Dark Theme - Primary Colors (Vibrant Purple-Blue)
  static const Color darkPrimary = Color(0xFF818CF8); // Indigo-400
  static const Color darkPrimaryLight = Color(0xFFA5B4FC); // Indigo-300
  static const Color darkPrimaryDark = Color(0xFF6366F1); // Indigo-500

  // Dark Theme - Secondary Colors (Vibrant Cyan)
  static const Color darkSecondary = Color(0xFF22D3EE); // Cyan-400
  static const Color darkSecondaryLight = Color(0xFF67E8F9); // Cyan-300
  static const Color darkSecondaryDark = Color(0xFF06B6D4); // Cyan-500

  // Dark Theme - Accent Colors (Vibrant Pink)
  static const Color darkAccent = Color(0xFFF472B6); // Pink-400
  static const Color darkAccentLight = Color(0xFFF9A8D4); // Pink-300
  static const Color darkAccentDark = Color(0xFFEC4899); // Pink-500

  // Dark Theme - Text Colors (Clear & Readable)
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Slate-100
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color darkTextHint = Color(0xFF64748B); // Slate-500

  // Dark Theme - Border Colors
  static const Color darkBorder = Color(0xFF334155); // Slate-700
  static const Color darkBorderLight = Color(0xFF475569); // Slate-600

  // Dark Theme - Divider
  static const Color darkDivider = Color(0xFF334155); // Slate-700

  // Dark Theme - Modern Gradients
  static const List<Color> darkPrimaryGradient = [Color(0xFF818CF8), Color(0xFFA78BFA)]; // Indigo to Purple
  static const List<Color> darkSecondaryGradient = [Color(0xFF22D3EE), Color(0xFF60A5FA)]; // Cyan to Blue
  static const List<Color> darkAccentGradient = [Color(0xFFF472B6), Color(0xFFFB923C)]; // Pink to Orange

  // ==================== ADDITIONAL MODERN DESIGN ELEMENTS ====================

  // Modern Gradient Sets for Cards and UI Components
  static const List<Color> gradientPurple = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const List<Color> gradientBlue = [Color(0xFF4F46E5), Color(0xFF06B6D4)];
  static const List<Color> gradientPink = [Color(0xFFEC4899), Color(0xFFF97316)];
  static const List<Color> gradientGreen = [Color(0xFF10B981), Color(0xFF3B82F6)];
  static const List<Color> gradientOrange = [Color(0xFFF59E0B), Color(0xFFEF4444)];
  static const List<Color> gradientTeal = [Color(0xFF14B8A6), Color(0xFF06B6D4)];

  // Glassmorphism Colors (for frosted glass effects)
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20000000);
  static const Color glassBorder = Color(0x30FFFFFF);

  // Glow/Shadow Colors for depth
  static const Color glowPrimary = Color(0x406366F1);
  static const Color glowSecondary = Color(0x4006B6D4);
  static const Color glowAccent = Color(0x40EC4899);
  static const Color glowSuccess = Color(0x4010B981);

  // Card Gradient Backgrounds
  static const List<Color> cardGradient1 = [Color(0xFFF8FAFC), Color(0xFFE2E8F0)];
  static const List<Color> cardGradient2 = [Color(0xFFEDE9FE), Color(0xFFDDD6FE)];
  static const List<Color> cardGradient3 = [Color(0xFFDCFCE7), Color(0xFFBBF7D0)];

  // Legacy gradient names (for backward compatibility)
  static const List<Color> modernGradient1 = gradientPurple;
  static const List<Color> modernGradient2 = gradientBlue;
  static const List<Color> modernGradient3 = gradientPink;
  static const List<Color> modernGradient4 = gradientGreen;
  static const List<Color> modernGradient5 = gradientOrange;
  static const List<Color> modernGradient6 = gradientTeal;

  // Neon colors (for special effects)
  static const Color neonGreen = Color(0xFF00FF85);
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF10F0);
  static const Color neonPurple = Color(0xFFBF40FF);
}

