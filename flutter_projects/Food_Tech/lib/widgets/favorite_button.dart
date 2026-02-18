import 'package:flutter/material.dart';
import 'heart_overlay.dart';
import 'dart:math' as math;

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _particleController;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    // Shorter duration for snappy feel (Instagram style)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Instagram-like spring effect: 0 -> 1.2 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      // Check if the current route is active to prevent background animations
      final route = ModalRoute.of(context);
      final isCurrent = route?.isCurrent ?? true;

      if (isCurrent) {
        if (widget.isFavorite) {
          _controller.forward(from: 0.0);
          _particleController.forward(from: 0.0);
          _showOverlay(true);
        } else {
          // No animation on the button itself when unliking usually, just state change
          // But maybe a small shrink for feedback
          // _controller.reverse(from: 1.0);
          _showOverlay(false);
        }
      }
    }
  }

  void _showOverlay(bool isLike) {
    // Schedule the overlay insertion for after the current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final OverlayState? overlayState = Overlay.of(context);
      if (overlayState == null) return;

      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Offset position = renderBox.localToGlobal(Offset.zero);
      final Size size = renderBox.size;

      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          // Position centered horizontally on the button, and slightly above
          return Positioned(
            top: position.dy - 30,
            left: position.dx + (size.width - 40) / 2,
            child: HeartOverlay(
              emoji: isLike ? '❤️' : '💔',
              onComplete: () {
                overlayEntry.remove();
              },
            ),
          );
        },
      );

      overlayState.insert(overlayEntry);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.5,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Transform.scale(
                scale: widget.isFavorite && _controller.isAnimating
                    ? _scaleAnimation.value
                    : 1.0,
                child: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite
                      ? const Color(0xFFED4956)
                      : Colors.grey[600], // Instagram Red & standard grey
                  size: widget.size,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
