import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homii_ai_event_comp_app/models/ai_message.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/user_avatar.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_close_button.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_container.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_handle.dart';

class MatchIntroModal extends StatelessWidget {
  final MatchIntroData introData;
  final bool isCopiable;

  const MatchIntroModal({
    super.key,
    required this.introData,
    required this.isCopiable,
  });

  static void show(
    BuildContext context, {
    required MatchIntroData introData,
    required bool isCopiable,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => MatchIntroModal(
        introData: introData,
        isCopiable: isCopiable,
      ),
    );
  }

  void _copyIceBreaker(BuildContext context) {
    Clipboard.setData(ClipboardData(text: introData.iceBreaker));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied intro message'),
        backgroundColor: AppColor.primary.color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final peer = introData.peer;

    return ModalContainer(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModalHandle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: Space.xl.value,
                    vertical: Space.md.value,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Space.lg.value,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: Space.sm.value,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColor.primary.color,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColor.white.color,
                                width: 4,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: UserAvatar(
                                imageKey: peer.profileImageKey,
                              ),
                            ),
                          ),
                          Text(
                            "It's a match! 🎉",
                            style: AppTextStyleNew.heading04.value(
                              color: AppColor.black.color,
                            ),
                          ),
                          Text(
                            peer.nickname,
                            style: AppTextStyleNew.body01Bold.value(
                              color: AppColor.black.color,
                            ),
                          ),
                        ],
                      ),

                      if ((peer.generatedProfileText ?? '').isNotEmpty ||
                          (peer.introduction ?? '').isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(Space.lg.value),
                          decoration: BoxDecoration(
                            color: AppColor.fgBeige.color,
                            borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Space.xs.value,
                            children: [
                              Text(
                                'Who they are',
                                style: AppTextStyleNew.body01Bold.value(
                                  color: AppColor.black.color,
                                ),
                              ),
                              if ((peer.introduction ?? '').isNotEmpty)
                                Text(
                                  peer.introduction!,
                                  style: AppTextStyleNew.body02.value(
                                    color: AppColor.textSecondary.color,
                                  ),
                                ),
                              if ((peer.generatedProfileText ?? '').isNotEmpty)
                                Text(
                                  peer.generatedProfileText!,
                                  style: AppTextStyleNew.body02.value(
                                    color: AppColor.textSecondary.color,
                                  ),
                                ),
                            ],
                          ),
                        ),

                      if (introData.topics.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Space.sm.value,
                          children: [
                            Text(
                              'Great topics to start with',
                              style: AppTextStyleNew.body01Bold.value(
                                color: AppColor.black.color,
                              ),
                            ),
                            Wrap(
                              spacing: Space.sm.value,
                              runSpacing: Space.sm.value,
                              children: introData.topics
                                  .map(
                                    (topic) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Space.md.value,
                                        vertical: Space.xs.value,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.bgBeige.color,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        topic,
                                        style: AppTextStyleNew.body02.value(
                                          color: AppColor.black.color,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Space.sm.value,
                        children: [
                          Text(
                            'Try saying this',
                            style: AppTextStyleNew.body01Bold.value(
                              color: AppColor.black.color,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Space.lg.value),
                            decoration: BoxDecoration(
                              color: AppColor.white.color,
                              borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                              border: Border.all(color: AppColor.bgDisabled.color),
                            ),
                            child: Text(
                              introData.iceBreaker,
                              style: AppTextStyleNew.body01.value(
                                color: AppColor.textDefault.color,
                              ),
                            ),
                          ),
                          if (isCopiable && introData.iceBreaker.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _copyIceBreaker(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary.color,
                                  foregroundColor: AppColor.white.color,
                                  padding: EdgeInsets.symmetric(
                                    vertical: Space.md.value,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                                  ),
                                ),
                                child: Text(
                                  'Copy intro message',
                                  style: AppTextStyleNew.body01Bold.value(
                                    color: AppColor.white.color,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Space.xl.value),
            ],
          ),
          ModalCloseButton(onClose: Navigator.of(context).pop),
        ],
      ),
    );
  }
}

