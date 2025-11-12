import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppAssetLottieWidget extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final bool animate;

  const AppAssetLottieWidget({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      animate: animate,
      decoder: customDecoder,
    );
  }

  Future<LottieComposition?> customDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        return files.firstWhere(
          (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'),
        );
      },
    );
  }
}
