import 'package:flutter/material.dart';

/// Modern Animation System
/// Provides consistent animation curves and durations
class AppAnimations {
  // ========== DURATIONS ==========

  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Specific use cases
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration dialogAnimation = Duration(milliseconds: 300);
  static const Duration bottomSheetAnimation = Duration(milliseconds: 400);
  static const Duration ripple = Duration(milliseconds: 200);
  static const Duration shimmer = Duration(milliseconds: 1500);

  // ========== CURVES ==========

  // Standard curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve linear = Curves.linear;

  // Bouncy animations
  static const Curve bounce = Curves.bounceOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceInOut = Curves.bounceInOut;

  // Elastic animations
  static const Curve elastic = Curves.elasticOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticInOut = Curves.elasticInOut;

  // Modern curves (Material 3)
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve accelerate = Curves.easeIn;

  // Custom curves
  static const Curve smoothStart = Curves.easeOutCubic;
  static const Curve smoothEnd = Curves.easeInCubic;
  static const Curve smooth = Curves.easeInOutCubic;

  // ========== TRANSITION BUILDERS ==========

  /// Fade transition
  static Widget fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Slide from bottom transition
  static Widget slideFromBottom(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasized,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide from right transition
  static Widget slideFromRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasized,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Scale transition
  static Widget scaleTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: emphasized,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Scale and fade (for dialogs)
  static Widget dialogTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: emphasized,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  // ========== PAGE ROUTES ==========

  /// Create a fade page route
  static PageRouteBuilder<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return fadeTransition(child, animation);
      },
    );
  }

  /// Create a slide from bottom page route
  static PageRouteBuilder<T> slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return slideFromBottom(child, animation);
      },
    );
  }

  /// Create a scale page route
  static PageRouteBuilder<T> scaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return scaleTransition(child, animation);
      },
    );
  }

  // ========== SHIMMER ANIMATION ==========

  /// Create a shimmer animation controller
  static AnimationController createShimmerController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: shimmer,
    )..repeat();
  }
}
