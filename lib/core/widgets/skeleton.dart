import 'dart:ui';

import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.08),
              ],
              stops: [t - 0.2, t, t + 0.2].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
          child: widget.child,
        ),
      ),
    );
  }
}
