import 'package:flutter/material.dart';

/// A widget that provides visual feedback animations for user actions
class AnimatedFeedback extends StatelessWidget {
  /// The child widget that will be animated
  final Widget child;
  
  /// The type of animation to apply
  final FeedbackType type;
  
  /// The duration of the animation
  final Duration duration;
  
  /// Whether the animation should repeat
  final bool repeat;
  
  /// Callback when animation completes
  final VoidCallback? onComplete;
  
  /// Scale factor for scale animations (if applicable)
  final double scaleFactor;

  const AnimatedFeedback({
    super.key,
    required this.child,
    this.type = FeedbackType.scale,
    this.duration = const Duration(milliseconds: 200),
    this.repeat = false,
    this.onComplete,
    this.scaleFactor = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case FeedbackType.scale:
        return _ScaleFeedback(
          child: child,
          duration: duration,
          repeat: repeat,
          onComplete: onComplete,
          scaleFactor: scaleFactor,
        );
      case FeedbackType.pulse:
        return _PulseFeedback(
          child: child,
          duration: duration,
          repeat: repeat,
          onComplete: onComplete,
          scaleFactor: scaleFactor,
        );
      case FeedbackType.shake:
        return _ShakeFeedback(
          child: child,
          duration: duration,
          repeat: repeat,
          onComplete: onComplete,
        );
      case FeedbackType.bounce:
        return _BounceFeedback(
          child: child,
          duration: duration,
          repeat: repeat,
          onComplete: onComplete,
        );
    }
  }
}

/// The types of feedback animations available
enum FeedbackType {
  /// A simple scale down and up animation
  scale,
  
  /// A pulsating animation
  pulse,
  
  /// A horizontal shake animation
  shake,
  
  /// A vertical bounce animation
  bounce,
}

/// A scale feedback animation implementation
class _ScaleFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;
  final VoidCallback? onComplete;
  final double scaleFactor;

  const _ScaleFeedback({
    required this.child,
    required this.duration,
    required this.repeat,
    this.onComplete,
    required this.scaleFactor,
  });

  @override
  State<_ScaleFeedback> createState() => _ScaleFeedbackState();
}

class _ScaleFeedbackState extends State<_ScaleFeedback> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// A pulsating animation implementation
class _PulseFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;
  final VoidCallback? onComplete;
  final double scaleFactor;

  const _PulseFeedback({
    required this.child,
    required this.duration,
    required this.repeat,
    this.onComplete,
    required this.scaleFactor,
  });

  @override
  State<_PulseFeedback> createState() => _PulseFeedbackState();
}

class _PulseFeedbackState extends State<_PulseFeedback> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.0 + (1.0 - widget.scaleFactor),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// A shake animation implementation
class _ShakeFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;
  final VoidCallback? onComplete;

  const _ShakeFeedback({
    required this.child,
    required this.duration,
    required this.repeat,
    this.onComplete,
  });

  @override
  State<_ShakeFeedback> createState() => _ShakeFeedbackState();
}

class _ShakeFeedbackState extends State<_ShakeFeedback> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      });
    }
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
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A bounce animation implementation
class _BounceFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;
  final VoidCallback? onComplete;

  const _BounceFeedback({
    required this.child,
    required this.duration,
    required this.repeat,
    this.onComplete,
  });

  @override
  State<_BounceFeedback> createState() => _BounceFeedbackState();
}

class _BounceFeedbackState extends State<_BounceFeedback> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: -10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      });
    }
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
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
} 