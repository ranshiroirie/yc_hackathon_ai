import 'package:flutter/material.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';

class ModalHandle extends StatelessWidget {
  const ModalHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Space.xs.value),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColor.gray20.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
