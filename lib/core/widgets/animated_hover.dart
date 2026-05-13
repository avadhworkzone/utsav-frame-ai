import 'package:flutter/material.dart';

class AnimatedHover extends StatefulWidget {
  const AnimatedHover({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.02,
    this.duration = const Duration(milliseconds: 140),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final Duration duration;

  @override
  State<AnimatedHover> createState() => _AnimatedHoverState();
}

class _AnimatedHoverState extends State<AnimatedHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: AnimatedScale(
          scale: _hovered ? widget.hoverScale : 1,
          duration: widget.duration,
          child: widget.child,
        ),
      ),
    );
  }
}

