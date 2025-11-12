import 'package:flutter/material.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';

/// Toast widget shown after successful connection request
/// Displays Lumi icon, title, and message
class ConnectionSuccessToast extends StatelessWidget {
  final String title;
  final String message;

  const ConnectionSuccessToast({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Space.md.value),
      decoration: BoxDecoration(
        color: AppColor.white.color,
        borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
        boxShadow: [AppBoxShadow.shadowMD.value],
      ),
      child: Row(
        spacing: Space.defaultt.value,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lumi icon
          SizedBox(
            width: 40,
            height: 40,
            child: AppAssetImageWidget(
              appAssetImage: AppAssetImage.lumii,
            ),
          ),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.x3s.value,
              children: [
                Text(
                  title,
                  style: AppTextStyleNew.body01Bold.value(
                    color: AppColor.black.color,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  Text(
                    message,
                    style: AppTextStyleNew.body02.value(
                      color: AppColor.black.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show the toast as a SnackBar
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Use Overlay to show toast above modals
    final overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + Space.xl.value,
        left: Space.xl.value,
        right: Space.xl.value,
        child: Material(
          color: Colors.transparent,
          child: _AnimatedToast(
            title: title,
            message: message,
            duration: duration,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

/// Animated wrapper for the toast that handles slide and fade animations
class _AnimatedToast extends StatefulWidget {
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Start animation
    _controller.forward();

    // Reverse animation and dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ConnectionSuccessToast(
          title: widget.title,
          message: widget.message,
        ),
      ),
    );
  }
}

