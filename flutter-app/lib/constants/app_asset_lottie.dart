const _basePath = "assets/lotties";

enum AppAssetLottie {
  confetti(
    lottiePath: "$_basePath/confetti.lottie",
  );

  final String lottiePath;

  const AppAssetLottie({
    required this.lottiePath,
  });
}
