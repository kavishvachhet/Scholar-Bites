import 'package:flutter/material.dart';

class AnimationUtils {
  static void runFlyAnimation(
    BuildContext context,
    GlobalKey startKey,
    GlobalKey endKey,
    String imageUrl, {
    VoidCallback? onComplete,
  }) {
    final OverlayState? overlayState = Overlay.of(context);
    if (overlayState == null) return;

    final RenderBox? startRenderBox =
        startKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? endRenderBox =
        endKey.currentContext?.findRenderObject() as RenderBox?;

    if (startRenderBox == null || endRenderBox == null) return;

    // Calculate center points
    final Offset startPosition =
        startRenderBox.localToGlobal(Offset.zero) +
        Offset(startRenderBox.size.width / 2, startRenderBox.size.height / 2);
    final Offset endPosition =
        endRenderBox.localToGlobal(Offset.zero) +
        Offset(endRenderBox.size.width / 2, endRenderBox.size.height / 2);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _FlyWidget(
          startPosition: startPosition,
          endPosition: endPosition,
          imageUrl: imageUrl,
          onComplete: () {
            overlayEntry.remove();
            if (onComplete != null) onComplete();
          },
        );
      },
    );

    overlayState.insert(overlayEntry);
  }
}

class _FlyWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String imageUrl;
  final VoidCallback onComplete;

  const _FlyWidget({
    required this.startPosition,
    required this.endPosition,
    required this.imageUrl,
    required this.onComplete,
  });

  @override
  State<_FlyWidget> createState() => _FlyWidgetState();
}

class _FlyWidgetState extends State<_FlyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Fade out / shrink at the end
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
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
        // Linear interpolation for X and Y
        // To make it parabolic/arc, we can use a custom curve or math here.
        // Simple Arc: add a vertical offset based on sin(pi * progress)

        final double t = _animation.value;
        final double dx =
            widget.startPosition.dx +
            (widget.endPosition.dx - widget.startPosition.dx) * t;
        final double dy =
            widget.startPosition.dy +
            (widget.endPosition.dy - widget.startPosition.dy) * t;

        // Arc height (negative is up)
        final double arcHeight =
            -100 * (4 * t * (1 - t)); // Parabola peak at t=0.5

        return Positioned(
          top: dy + arcHeight,
          left: dx,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _scaleAnimation.value.clamp(0.0, 1.0), // Fade with scale
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
