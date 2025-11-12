import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';

/// Reusable chat bubble with a small rounded tail.
class ChatBubble extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onTap;
  final double tailWidth;
  final double tailHeight;
  final double tailOffsetFraction; // 0..1 along width
  final EdgeInsetsGeometry padding;
  final double minWidth;
  final double maxWidth;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final BoxShadow? boxShadow;
  final TextAlign? textAlign;

  const ChatBubble({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
    this.tailWidth = 20,
    this.tailHeight = 14,
    this.tailOffsetFraction = 0.5, // Centered tail
    this.padding = const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
    this.minWidth = 260,
    this.maxWidth = 700,
    this.backgroundColor,
    this.textStyle,
    this.boxShadow,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Max width should be screen width - 48 (24px horizontal margins)
    final targetMaxWidth = math.max(0, screenWidth - 48);
    final resolvedMaxWidth = math.min(maxWidth, targetMaxWidth);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: BubblePainter(
            color: backgroundColor ?? AppColor.white.color,
            shadow: boxShadow ?? AppBoxShadow.shadowSM.value,
            tailWidth: tailWidth,
            tailHeight: tailHeight,
            tailOffsetFraction: tailOffsetFraction,
          ),
          child: Container(
            padding: padding,
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: resolvedMaxWidth.toDouble(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: textAlign == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: textAlign,
                  style: textStyle ??
                      AppTextStyleNew.body01Bold.value(
                        color: AppColor.black.color,
                      ),
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    message,
                    textAlign: textAlign,
                    style: textStyle ??
                        AppTextStyleNew.body02.value(
                          color: AppColor.black.color,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final Color color;
  final BoxShadow shadow;
  final double tailWidth;
  final double tailHeight;
  final double tailOffsetFraction; // 0..1 along width

  BubblePainter({
    required this.color,
    required this.shadow,
    this.tailWidth = 18,
    this.tailHeight = 10,
    this.tailOffsetFraction = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = 20.0;
    final tailW = tailWidth;
    final tailH = tailHeight;
    // Clamp offset so the tail does not collide with rounded corners
    final clamped = tailOffsetFraction.clamp(0.1, 0.9);
    final tailX = size.width * clamped;

    final bubbleRect =
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height - tailH), Radius.circular(r));

    // Shadow
    final shadowPaint = Paint()
      ..color = shadow.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
    final shadowPath = Path()..addRRect(bubbleRect);
    canvas.save();
    canvas.translate(shadow.offset.dx, shadow.offset.dy);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // Bubble
    final paint = Paint()..color = color;
    final path = Path()..addRRect(bubbleRect);

    // Tail (sharp triangle, attached to bubble bottom, centered by tailX)
    final tail = Path()
      // Start at left attach point on bubble bottom edge
      ..moveTo(tailX - tailW / 2, size.height - tailH)
      // Draw straight line to sharp tip at bottom
      ..lineTo(tailX, size.height)
      // Draw straight line back to right attach point
      ..lineTo(tailX + tailW / 2, size.height - tailH)
      // Close the path back to start
      ..close();

    path.addPath(tail, Offset.zero);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


