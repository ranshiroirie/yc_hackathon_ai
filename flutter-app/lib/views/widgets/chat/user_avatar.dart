import 'package:flutter/material.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';

class UserAvatar extends StatelessWidget {
  final int imageKey;

  const UserAvatar({
    super.key,
    required this.imageKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppAssetImageWidget(
      appAssetImage: AppAssetImage.values.firstWhere(
        (e) => e.imagePath.contains('avatar_${imageKey.toString()}'),
        orElse: () => AppAssetImage.avatar1,
      ),
    );
  }
}