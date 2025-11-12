import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/models/recommendation_candidate.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_close_button.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_container.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_handle.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/user_avatar.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';
import 'package:homii_ai_event_comp_app/providers/functions_provider.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/connection_success_toast.dart';

/// Modal for displaying FOUND_MATCH candidates
class FoundMatchModal extends ConsumerStatefulWidget {
  final List<RecommendationCandidate> candidates;

  const FoundMatchModal({
    super.key,
    required this.candidates,
  });

  /// Show the modal as a bottom sheet
  static void show(
    BuildContext context, {
    required List<RecommendationCandidate> candidates,
  }) {
    if (candidates.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => FoundMatchModal(
        candidates: candidates,
      ),
    );
  }

  @override
  ConsumerState<FoundMatchModal> createState() => _FoundMatchModalState();
}

class _FoundMatchModalState extends ConsumerState<FoundMatchModal> {
  String? _loadingUid;

  Future<void> _handleProposeConnection(
    BuildContext context,
    WidgetRef ref,
    RecommendationCandidate candidate,
  ) async {
    setState(() {
      _loadingUid = candidate.uid;
    });
    try {
      if (candidate.isPredata) {
        await Future.delayed(const Duration(seconds: 3));
        if (!context.mounted) return;
        ConnectionSuccessToast.show(
          context,
          title: "I'll go say hi to ${candidate.nickname}!",
          message: "I'll share their intro once they're ready to connect.",
        );
      } else {
        final functionsService = ref.read(functionsServiceProvider);
        await functionsService.proposeConnection(toUid: candidate.uid);

        // Show toast using Overlay (above modal)
        if (context.mounted) {
          ConnectionSuccessToast.show(
            context,
            title: "I'll introduce you to ${candidate.nickname}!",
            message:
                "If ${candidate.nickname} is interested, I'll connect you both.",
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
    } finally {
      if (mounted) {
        setState(() {
          _loadingUid = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalHandle(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Space.xs.value),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: Space.xs.value,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: AppAssetImageWidget(
                        appAssetImage: AppAssetImage.lumii,
                      ),
                    ),
                    Text(
                      'Discover with Lumi',
                      style: AppTextStyleNew.body01Bold.value(
                        color: AppColor.black.color
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Space.md.value),

              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: Space.md.value),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'I found some interesting people you might connect well with:',
                        style: AppTextStyleNew.body01.value(
                          color: AppColor.black.color,
                        ),
                      ),
                      SizedBox(height: Space.lg.value),
                      ...widget.candidates.map(
                        (candidate) => Padding(
                          padding: EdgeInsets.only(bottom: Space.x2l.value),
                          child: _CandidateCard(
                            candidate: candidate,
                            isLoading: _loadingUid == candidate.uid,
                            isDisabled: _loadingUid != null && _loadingUid != candidate.uid,
                            onConnect: (_loadingUid == null)
                                  ? () => _handleProposeConnection(
                                        context,
                                        ref,
                                        candidate,
                                      )
                                : null, // null disables the button
                          ),
                        ),
                      ),
                      SizedBox(height: Space.xl.value),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ModalCloseButton(onClose: Navigator.of(context).pop)
        ],
      )
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final RecommendationCandidate candidate;
  final VoidCallback? onConnect;
  final bool isLoading;
  final bool isDisabled;

  const _CandidateCard({
    required this.candidate,
    required this.onConnect,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ${candidate.nickname}',
          style: AppTextStyleNew.body01Bold.value(
            color: AppColor.black.color,
          ),
        ),
        Text(
          candidate.reason,
          style: AppTextStyleNew.body01.value(
            color: AppColor.black.color,
          ),
        ),

        SizedBox(height: Space.xl.value),
        // Candidate card
        Container(
          padding: EdgeInsets.only(top: Space.lg.value, left: Space.lg.value, right: Space.lg.value),
          decoration: BoxDecoration(
            color: AppColor.fgBeige.color,
            borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
            boxShadow: [AppBoxShadow.shadowCardElevated.value],
          ),
          child: Transform.translate(
            offset: Offset(0, -32),
            child: Column(
              children: [
                // Large avatar
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
                    child: UserAvatar(imageKey: candidate.profileImageKey),
                  ),
                ),
                SizedBox(height: Space.md.value),

                Text(
                  candidate.nickname,
                  style: AppTextStyleNew.heading04.value(
                    color: AppColor.black.color,
                  ),
                ),
                SizedBox(height: Space.xs.value),
                Text(
                  candidate.reason,
                  style: AppTextStyleNew.body02.value(
                    color: AppColor.gray60.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Space.md.value),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isDisabled || isLoading) ? null : onConnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary.color,
                      foregroundColor: AppColor.white.color,
                      padding: EdgeInsets.symmetric(vertical: Space.defaultt.value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColor.white.color),
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: AppAssetImageWidget(
                                  appAssetImage: AppAssetImage.lumii,
                                ),
                              ),
                              SizedBox(width: Space.xs.value),
                              Text(
                                'Connect me',
                                style: AppTextStyleNew.body02Bold.value(
                                  color: AppColor.white.color,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}
