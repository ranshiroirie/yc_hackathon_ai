import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';
import 'personal_information/name_screen.dart';

/// Landing screen - Initial screen for profile setup
/// Anonymous sign-in is handled automatically in RootScreen
class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  static const List<AppAssetImage> personImages = [
    AppAssetImage.person1,
    AppAssetImage.person2,
    AppAssetImage.person3,
    AppAssetImage.person4,
    AppAssetImage.person5,
    AppAssetImage.person6,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.bgBeige.color,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppAssetImageWidget(
              appAssetImage: AppAssetImage.landingBackground,
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: Space.x3l.value,
                        left: Space.md.value,
                        right: Space.md.value,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          spacing: Space.x3l.value,
                          children: [
                            Column(
                              spacing: Space.md.value,
                              children: [
                                Container(
                                  width: 240,
                                  height: 240,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(45),
                                    ),
                                    shadows: [
                                      AppBoxShadow.shadowMD.value,
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(45),
                                    child: AppAssetImageWidget(
                                      appAssetImage: AppAssetImage.event,
                                    ),
                                  ),
                                ),

                                Column(
                                  spacing: Space.xs.value,
                                  children: [
                                    Text(
                                      'VIBE25-5: Welcome to\nSan Fransokyo',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyleNew.heading02.value(
                                        color: AppColor.black.color,
                                      ),
                                    ),
                                    Text(
                                      'https://luma.com/whkm8jf2?tk=Ied2kk',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyleNew.body02.value(
                                        color: AppColor.gray60.color,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            Column(
                              spacing: Space.md.value,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: personImages.length * 28 + Space.xs.value,
                                  child: Stack(
                                    children: [
                                      ...List.generate(personImages.length, (index) =>
                                        Transform.translate(
                                          offset: Offset(index * 28, 0),
                                          child: _buildPersonImage(personImages[index]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  '23 people are already awaiting you! ✨ ',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyleNew.body01.value(
                                    color: AppColor.black.color,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      )
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: Space.md.value,
                      right: Space.md.value,
                      top: Space.xl.value,
                      bottom: Space.x3l.value,
                    ),
                    color: AppColor.white.color.withValues(alpha: 0.5),
                    child: Column(
                      spacing: Space.md.value,
                      children: [
                        SizedBox(
                          width: 224,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const NameScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary.color,
                              foregroundColor: AppColor.white.color,
                              padding: EdgeInsets.symmetric(
                                vertical: Space.md.value,
                                horizontal: Space.lg.value,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: Space.xs.value,
                              children: [
                                Text(
                                  'Join with AI',
                                  style: AppTextStyleNew.body01Bold.value(
                                    color: AppColor.white.color,
                                  ),
                                ),

                                AppAssetImageWidget(
                                  appAssetImage: AppAssetImage.arrowRight,
                                ),
                              ],
                            )
                          ),
                        ),

                        Text(
                          'Experience the future of networking 🪄',
                          textAlign: TextAlign.center,
                          style: AppTextStyleNew.body01Bold.value(
                            color: AppColor.black.color,
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _buildPersonImage(AppAssetImage appAssetImage) {
    return Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AppAssetImageWidget(appAssetImage: appAssetImage),
      ),
    );
  }
}

