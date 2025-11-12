enum AppAssetImageType {
  svg,
  raster,
}

const _basePath = "assets/images";
const _avatarPath = "assets/images/avatars";
const _iconPath = "assets/icons";

enum AppAssetImage {
  arrowRight(
    imageType: AppAssetImageType.svg,
    imagePath: "$_iconPath/arrow_right.svg",
  ),

  event(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/event.png",
  ),
  landingBackground(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/landing_background.png",
  ),

  person1(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/person_1.png",
  ),
  person2(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/person_2.png",
  ),
  person3(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/person_3.png",
  ),
  person4(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/person_4.png",
  ),
  person5(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/person_5.png",
  ),
  person6(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/person_6.png",
  ),

  avatar1(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_1.png",
  ),
  avatar2(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_2.png",
  ),
  avatar3(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_3.png",
  ),
  avatar4(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_4.png",
  ),
  avatar5(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_5.png",
  ),
  avatar6(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_6.png",
  ),
  avatar7(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_7.png",
  ),
  avatar8(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_8.png",
  ),
  avatar9(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_9.png",
  ),
  avatar10(
    imageType: AppAssetImageType.raster,
    imagePath: "$_avatarPath/avatar_10.png",
  ),

  lumii(
    imageType: AppAssetImageType.raster,
    imagePath: "$_basePath/lumii.png",
  );

  final AppAssetImageType imageType;
  final String imagePath;

  const AppAssetImage({
    required this.imageType,
    required this.imagePath,
  });
}