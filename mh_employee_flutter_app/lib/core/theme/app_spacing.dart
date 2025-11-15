/// Modern Spacing System
/// Provides consistent spacing values across the app
class AppSpacing {
  // Base spacing unit (4px)
  static const double unit = 4.0;

  // Micro spacing (for tight layouts)
  static const double xs = unit; // 4px
  static const double sm = unit * 2; // 8px

  // Standard spacing
  static const double md = unit * 3; // 12px
  static const double lg = unit * 4; // 16px
  static const double xl = unit * 5; // 20px
  static const double xxl = unit * 6; // 24px

  // Macro spacing (for sections)
  static const double xxxl = unit * 8; // 32px
  static const double huge = unit * 10; // 40px
  static const double massive = unit * 12; // 48px

  // Common padding combinations
  static const double paddingHorizontal = lg; // 16px
  static const double paddingVertical = lg; // 16px
  static const double cardPadding = lg; // 16px
  static const double sectionPadding = xxl; // 24px
  static const double screenPadding = lg; // 16px

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 999.0;

  // Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // AppBar height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;

  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
  static const double cardMinHeight = 100.0;

  // Grid spacing
  static const double gridSpacing = lg;
  static const double gridSpacingLarge = xl;

  // List item heights
  static const double listItemHeight = 56.0;
  static const double listItemHeightLarge = 72.0;
  static const double listItemHeightCompact = 48.0;
}
