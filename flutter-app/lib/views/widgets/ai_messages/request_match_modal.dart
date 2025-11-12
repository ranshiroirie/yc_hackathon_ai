import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/models/ai_message.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/user_avatar.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';
import 'package:homii_ai_event_comp_app/providers/functions_provider.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/connection_success_toast.dart';

/// Modal for displaying REQUEST_MATCH
class RequestMatchModal extends ConsumerWidget {
  final RequestMatchData requestData;

  const RequestMatchModal({
    super.key,
    required this.requestData,
  });

  /// Show the modal as a bottom sheet
  static void show(
    BuildContext context, {
    required RequestMatchData requestData,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => RequestMatchModal(
        requestData: requestData,
      ),
    );
  }

  Future<void> _handleRespondConnection(
    BuildContext context,
    WidgetRef ref,
    String fromUid,
    bool accept,
  ) async {
    try {
      final functionsService = ref.read(functionsServiceProvider);
      await functionsService.respondConnection(
        fromUid: fromUid,
        accept: accept,
      );
      if (context.mounted) {
        // Show toast using Overlay (above modal)
        if (accept) {
          ConnectionSuccessToast.show(
            context,
            title: "I'll introduce you to Emma!",
            message: "If Emma is interested, I'll connect you both.",
          );
        }
      }
    } catch (e) {
      // Show error using Overlay (above modal)
      if (context.mounted) {
        final overlay = Overlay.of(context, rootOverlay: true);
        late OverlayEntry overlayEntry;
        overlayEntry = OverlayEntry(
            builder: (context) => Positioned(
              top: MediaQuery.of(context).padding.top + Space.xl.value,
              left: Space.xl.value,
              right: Space.xl.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(Space.md.value),
                  decoration: BoxDecoration(
                    color: AppColor.danger.color,
                    borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                    boxShadow: [AppBoxShadow.shadowMD.value],
                  ),
                  child: Text(
                    'Error: ${e.toString()}',
                    style: AppTextStyleNew.body01.value(
                      color: AppColor.white.color,
                    ),
                  ),
                ),
              ),
            ),
          );
        overlay.insert(overlayEntry);
        Future.delayed(const Duration(seconds: 3), () {
          overlayEntry.remove();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxxl.value),
          topRight: Radius.circular(AppRadius.xxxl.value),
        ),
      ),
      insetPadding: EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with drag handle
            Container(
              padding: EdgeInsets.only(
                top: Space.md.value,
                left: Space.xl.value,
                right: Space.xl.value,
                bottom: Space.md.value,
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.gray20.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: Space.md.value),
                  // Header row
                  Row(
                    children: [
                      // Lumi icon
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: AppAssetImageWidget(
                          appAssetImage: AppAssetImage.lumii,
                        ),
                      ),
                      SizedBox(width: Space.xs.value),
                      Text(
                        'Discover with Lumi',
                        style: AppTextStyleNew.heading03.value(
                          color: AppColor.black.color,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Space.xl.value),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: Space.md.value),
                    Text(
                      'Hi ${requestData.candidate.nickname}! 👋',
                      style: AppTextStyleNew.heading04.value(
                        color: AppColor.black.color,
                      ),
                    ),
                    SizedBox(height: Space.xs.value),
                    Text(
                      '${requestData.candidate.nickname} would like to connect with you!',
                      style: AppTextStyleNew.body01.value(
                        color: AppColor.black.color,
                      ),
                    ),
                    SizedBox(height: Space.md.value),
                    Text(
                      'What caught their attention:',
                      style: AppTextStyleNew.body01Bold.value(
                        color: AppColor.black.color,
                      ),
                    ),
                    SizedBox(height: Space.xs.value),
                    Text(
                      requestData.reason,
                      style: AppTextStyleNew.body02.value(
                        color: AppColor.textSecondary.color,
                      ),
                    ),
                    SizedBox(height: Space.xs.value),
                    Text(
                      '• ${requestData.candidate.nickname}',
                      style: AppTextStyleNew.body02.value(
                        color: AppColor.textSecondary.color,
                      ),
                    ),
                    SizedBox(height: Space.lg.value),
                    // Requester card
                    Container(
                      padding: EdgeInsets.all(Space.lg.value),
                      decoration: BoxDecoration(
                        color: AppColor.containerBg.color,
                        borderRadius: BorderRadius.circular(AppRadius.xl.value),
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColor.primary.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: UserAvatar(
                                imageKey: requestData.candidate.profileImageKey,
                              ),
                            ),
                          ),
                          SizedBox(height: Space.md.value),
                          Text(
                            requestData.candidate.nickname,
                            style: AppTextStyleNew.heading04.value(
                              color: AppColor.black.color,
                            ),
                          ),
                          SizedBox(height: Space.sm.value),
                          Text(
                            requestData.reason,
                            style: AppTextStyleNew.body02.value(
                              color: AppColor.textSecondary.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Space.lg.value),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _handleRespondConnection(
                                context,
                                ref,
                                requestData.fromUid,
                                true,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary.color,
                                foregroundColor: AppColor.white.color,
                                padding: EdgeInsets.symmetric(vertical: Space.md.value),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: AppAssetImageWidget(
                                      appAssetImage: AppAssetImage.lumii,
                                    ),
                                  ),
                                  SizedBox(width: Space.xs.value),
                                  Text(
                                    'Say hi',
                                    style: AppTextStyleNew.body01Bold.value(
                                      color: AppColor.white.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Space.xl.value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

