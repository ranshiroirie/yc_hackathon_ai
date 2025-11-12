import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';

class AppAssetImageWidget extends StatelessWidget {
  final AppAssetImage appAssetImage;
  final Color? color;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const AppAssetImageWidget({
    super.key,
    required this.appAssetImage,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    switch (appAssetImage.imageType) {
      case AppAssetImageType.svg:
        return SvgPicture.asset(
          appAssetImage.imagePath,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          fit: fit,
        );
      case AppAssetImageType.raster:
        return Image.asset(
          appAssetImage.imagePath,
          color: color,
          fit: fit,
          alignment: alignment,
        );
    }
  }
}
