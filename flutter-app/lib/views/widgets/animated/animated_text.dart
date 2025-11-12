import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.textColor,
    required this.isLast,
    this.isEntranceOutEnabled = false,
    this.onComplete,
    this.delayIn = const Duration(milliseconds: 300),
    this.delayOut = const Duration(milliseconds: 300),
  });

  final String text;
  final double fontSize;
  final Color textColor;
  final bool isLast;
  final bool isEntranceOutEnabled;
  final Duration delayIn;
  final Duration delayOut;
  final VoidCallback? onComplete;

  @override
  AnimatedTextState createState() => AnimatedTextState();
}

class AnimatedTextState extends State<AnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.isEntranceOutEnabled) {
        _reverseAnimation();
      }

      if (status == AnimationStatus.dismissed &&
          widget.isLast &&
          widget.onComplete != null) {
        widget.onComplete!();
      }
    });

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delayIn, () {
      _controller.forward();
    });
  }

  void _reverseAnimation() {
    Future.delayed(widget.delayOut, () {
      _offsetAnimation = Tween<Offset>(
        begin: const Offset(0, -30),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _opacityAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _offsetAnimation.value.dx,
              _offsetAnimation.value.dy,
            ),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontFamily: 'Perfectly Nineties',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
