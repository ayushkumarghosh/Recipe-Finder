import 'package:flutter/material.dart';

/// A collection of custom page transitions to enhance app navigation.
class PageTransitions {
  /// Slide transition from right to left (for forward navigation)
  static Route<T> slideTransition<T>(
    Widget page, {
    int milliseconds = 300,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: milliseconds),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Fade transition for a smooth appearance
  static Route<T> fadeTransition<T>(
    Widget page, {
    int milliseconds = 300,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: milliseconds),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale and fade transition for a zoom effect
  static Route<T> scaleTransition<T>(
    Widget page, {
    int milliseconds = 300,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: milliseconds),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeOutQuint;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);
        
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }
} 