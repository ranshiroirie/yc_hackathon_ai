import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/screens/personal_information/goals_screen.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/user_avatar.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';

/// Personal information - Self introduction preview screen
/// Shows the generated profile summary before final edits
class SelfIntroScreen extends ConsumerStatefulWidget {
  final String nickname;
  final String linkedinId;
  final String generatedProfileText;
  final int profileImageKey;

  const SelfIntroScreen({
    super.key,
    required this.nickname,
    required this.linkedinId,
    required this.generatedProfileText,
    required this.profileImageKey,
  });

  @override
  ConsumerState<SelfIntroScreen> createState() => _SelfIntroScreenState();
}

class _SelfIntroScreenState extends ConsumerState<SelfIntroScreen> {
  void _handleNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GoalsScreen(
          nickname: widget.nickname,
          linkedinId: widget.linkedinId,
          generatedProfileText: widget.generatedProfileText,
          profileImageKey: widget.profileImageKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgBeige.color,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: Space.xl.value,
            right: Space.xl.value,
            top: Space.x2l.value,
            bottom: Space.x3l.value,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: Space.xl.value,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: AppAssetImageWidget(
                          appAssetImage: AppAssetImage.lumii,
                        ),
                      ),

                      Text(
                        "Done",
                        textAlign: TextAlign.center,
                        style: AppTextStyleNew.heading03.value(
                          color: AppColor.black.color,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.all(Space.xl.value),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppRadius.xxxl.value,
                          ),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Column(
                          spacing: Space.sm.value,
                          children: [
                            Row(
                              spacing: Space.xs.value,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColor.primary.color,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: UserAvatar(
                                      imageKey: widget.profileImageKey,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.nickname,
                                  style: AppTextStyleNew.heading04.value(
                                    color: AppColor.black.color,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              widget.generatedProfileText,
                              style: AppTextStyleNew.body02.value(
                                color: AppColor.black.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ),

              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary.color,
                  foregroundColor: AppColor.white.color,
                  disabledBackgroundColor: AppColor.bgDisabled.color,
                  padding: EdgeInsets.symmetric(vertical: Space.md.value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyleNew.body01Bold.value(
                    color: AppColor.white.color,
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}

