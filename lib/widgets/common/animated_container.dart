import 'package:flutter/material.dart';

class AnimatedScaleContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback? onTap;

  const AnimatedScaleContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
  }) : super(key: key);

  @override
  _AnimatedScaleContainerState createState() => _AnimatedScaleContainerState();
}

class _AnimatedScaleContainerState extends State<AnimatedScaleContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }
}