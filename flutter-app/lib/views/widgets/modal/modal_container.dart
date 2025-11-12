import 'package:flutter/material.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';

class ModalContainer extends StatelessWidget {
  final Widget child;
  final bool isSemiModal;
  final double? heightMultiplier;
  final double? height;

  const ModalContainer({
    required this.child,
    this.isSemiModal = false,
    this.heightMultiplier,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final multiplier = heightMultiplier ?? (isSemiModal ? 0.4 : 0.925);

    return Container(
      height: height ?? MediaQuery.of(context).size.height * multiplier,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColor.bgBeige.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: child,
    );
  }
}
