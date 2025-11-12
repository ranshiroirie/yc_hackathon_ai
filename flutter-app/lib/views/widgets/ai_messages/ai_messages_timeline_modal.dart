import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/models/ai_message.dart';
import 'package:homii_ai_event_comp_app/models/recommendation_candidate.dart';
import 'package:homii_ai_event_comp_app/providers/functions_provider.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/user_avatar.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/connection_success_toast.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_close_button.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_container.dart';
import 'package:homii_ai_event_comp_app/views/widgets/modal/modal_handle.dart';
import 'package:url_launcher/url_launcher.dart';

class AiMessagesTimelineModal extends ConsumerWidget {
  final List<AiMessage> messages;
  final BuildContext parentContext;

  const AiMessagesTimelineModal({
    super.key,
    required this.messages,
    required this.parentContext,
  });

  static void show(
    BuildContext parentContext, {
    required List<AiMessage> messages,
  }) {
    if (messages.isEmpty) return;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => AiMessagesTimelineModal(
        messages: messages,
        parentContext: parentContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModalContainer(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModalHandle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Space.xl.value,
                    Space.md.value,
                    Space.xl.value,
                    Space.xl.value,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Space.xl.value,
                    children: [
                      _buildHeader(),
                      ...messages.reversed
                          .map(
                            (message) =>
                                _buildMessageSection(context, ref, message),
                          )
                          .where((widget) => widget != null)
                          .cast<Widget>()
                          .toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ModalCloseButton(onClose: Navigator.of(context).pop),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        spacing: Space.sm.value,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: AppColor.black.color,
                ),
              ),
            ],
          ),
          Text(
            'Here’s everything Lumi has shared with you so far.',
            textAlign: TextAlign.center,
            style: AppTextStyleNew.body02.value(
              color: AppColor.textSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildMessageSection(
      BuildContext context, WidgetRef ref, AiMessage message) {
    switch (message.type) {
      case AiMessageType.foundMatch:
        return _FoundMatchSection(
          ref: ref,
          parentContext: parentContext,
          message: message,
        );
      case AiMessageType.requestMatch:
        final data = message.requestMatchData;
        if (data == null) return null;
        return _RequestMatchSection(
          ref: ref,
          parentContext: parentContext,
          message: message,
        );
      case AiMessageType.matchIntro:
        final intro = message.matchIntroData;
        if (intro == null) return null;
        return _MatchIntroSection(
          ref: ref,
          parentContext: parentContext,
          message: message,
        );
    }
  }
}

class _FoundMatchSection extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext parentContext;
  final AiMessage message;

  const _FoundMatchSection({
    required this.ref,
    required this.parentContext,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final candidates = message.candidates;
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.lg.value,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _formatTimestamp(message.createdAt),
            style: AppTextStyleNew.caption02.value(
              color: AppColor.textSecondary.color,
            ),
          ),
        ),
        Text(
          'Lumi found some interesting people you might connect well with:',
          style: AppTextStyleNew.body01.value(
            color: AppColor.black.color,
          ),
        ),
        ...candidates.map((candidate) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Space.sm.value,
            children: [
              Text(
                '• ${candidate.nickname}: ${candidate.reason}',
                style: AppTextStyleNew.body02.value(
                  color: AppColor.black.color,
                ),
              ),
              _CandidatePreviewCard(
                ref: ref,
                parentContext: parentContext,
                candidate: candidate,
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _CandidatePreviewCard extends StatefulWidget {
  final WidgetRef ref;
  final BuildContext parentContext;
  final RecommendationCandidate candidate;

  const _CandidatePreviewCard({
    required this.ref,
    required this.parentContext,
    required this.candidate,
  });

  @override
  State<_CandidatePreviewCard> createState() => _CandidatePreviewCardState();
}

class _CandidatePreviewCardState extends State<_CandidatePreviewCard> {
  bool _isLoading = false;

  Future<void> _handleConnect() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final service = widget.ref.read(functionsServiceProvider);
      await service.proposeConnection(toUid: widget.candidate.uid);
      if (!mounted) return;

      if (widget.candidate.isPredata) {
        ConnectionSuccessToast.show(
          widget.parentContext,
          title: "I'll go say hi to ${widget.candidate.nickname}!",
          message: "I'll share their intro once they're ready to connect.",
        );
      } else {
        ConnectionSuccessToast.show(
          widget.parentContext,
          title: "I'll introduce you to ${widget.candidate.nickname}!",
          message:
              "If ${widget.candidate.nickname} is interested, I'll connect you both.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColor.danger.color,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: Space.lg.value,
        left: Space.lg.value,
        right: Space.lg.value,
        bottom: Space.lg.value,
      ),
      decoration: BoxDecoration(
        color: AppColor.fgBeige.color,
        borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
        boxShadow: [AppBoxShadow.shadowCardElevated.value],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              child: UserAvatar(imageKey: widget.candidate.profileImageKey),
            ),
          ),
          SizedBox(height: Space.md.value),
          Text(
            widget.candidate.nickname,
            style: AppTextStyleNew.heading04.value(
              color: AppColor.black.color,
            ),
          ),
          SizedBox(height: Space.sm.value),
          Text(
            widget.candidate.introduction,
            textAlign: TextAlign.center,
            style: AppTextStyleNew.body02.value(
              color: AppColor.textSecondary.color,
            ),
          ),
          SizedBox(height: Space.md.value),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary.color,
                foregroundColor: AppColor.white.color,
                padding: EdgeInsets.symmetric(
                  vertical: Space.defaultt.value,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColor.white.color),
                      ),
                    )
                  : Text(
                      'Connect me',
                      style: AppTextStyleNew.body02Bold.value(
                        color: AppColor.white.color,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestMatchSection extends StatefulWidget {
  final WidgetRef ref;
  final BuildContext parentContext;
  final AiMessage message;

  const _RequestMatchSection({
    required this.ref,
    required this.parentContext,
    required this.message,
  });

  @override
  State<_RequestMatchSection> createState() => _RequestMatchSectionState();
}

class _RequestMatchSectionState extends State<_RequestMatchSection> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.message.requestMatchData;
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.md.value,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _formatTimestamp(widget.message.createdAt),
            style: AppTextStyleNew.caption02.value(
              color: AppColor.textSecondary.color,
            ),
          ),
        ),
        Text(
          'Someone wants to connect with you! 🎉',
          style: AppTextStyleNew.body01.value(
            color: AppColor.black.color,
          ),
        ),
        Text(
          data.reason,
          style: AppTextStyleNew.body02.value(
            color: AppColor.textSecondary.color,
          ),
        ),
        Container(
          padding: EdgeInsets.all(Space.lg.value),
          decoration: BoxDecoration(
            color: AppColor.containerBg.color,
            borderRadius: BorderRadius.circular(AppRadius.xl.value),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: Space.md.value,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColor.primary.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: UserAvatar(imageKey: data.candidate.profileImageKey),
                ),
              ),
              Text(
                data.candidate.nickname,
                style: AppTextStyleNew.heading04.value(
                  color: AppColor.black.color,
                ),
              ),
              Text(
                data.reason,
                textAlign: TextAlign.center,
                style: AppTextStyleNew.body02.value(
                  color: AppColor.textSecondary.color,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleRespond(data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary.color,
                    foregroundColor: AppColor.white.color,
                    padding: EdgeInsets.symmetric(vertical: Space.md.value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.white.color,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: Space.xs.value,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: AppAssetImageWidget(
                                appAssetImage: AppAssetImage.lumii,
                              ),
                            ),
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
      ],
    );
  }

  Future<void> _handleRespond(RequestMatchData data) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.ref.read(functionsServiceProvider).respondConnection(
            fromUid: data.fromUid,
            accept: true,
          );
      if (!mounted) return;
      ConnectionSuccessToast.show(
        widget.parentContext,
        title: "I'll introduce you to ${data.candidate.nickname}!",
        message:
            "If ${data.candidate.nickname} is interested, I'll connect you both.",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColor.danger.color,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _MatchIntroSection extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext parentContext;
  final AiMessage message;

  const _MatchIntroSection({
    required this.ref,
    required this.parentContext,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final intro = message.matchIntroData;
    if (intro == null) return const SizedBox.shrink();

    final peer = intro.peer;
    final meta = message.payload['meta'];
    final isAutoSayHi =
        meta is Map && (meta['autoSayHi'] == true || meta['auto_say_hi'] == true);
    final profileUrl = _profileUrlForPeer(peer);
    final headingText = isAutoSayHi
        ? "I said hi to ${peer.nickname}! I'll let you know when they respond."
        : "It's a match! 🎉 You and ${peer.nickname} both want to connect!";
    final hasIceBreaker = intro.iceBreaker.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.md.value,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _formatTimestamp(message.createdAt),
            style: AppTextStyleNew.caption02.value(
              color: AppColor.textSecondary.color,
            ),
          ),
        ),
        Text(
          headingText,
          style: AppTextStyleNew.body01.value(
            color: AppColor.black.color,
          ),
        ),
        if (profileUrl != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.x3s.value,
            children: [
              Text(
                'Reach him here:',
                style: AppTextStyleNew.body01Bold.value(
                  color: AppColor.black.color,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _launchUrl(profileUrl),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Space.x3s.value),
                  child: Text(
                    profileUrl,
                    style: AppTextStyleNew.body02Underline.value(
                      color: AppColor.primary.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (intro.topics.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.x3s.value,
            children: [
              Text(
                'Topics to explore together:',
                style: AppTextStyleNew.body01Bold.value(
                  color: AppColor.black.color,
                ),
              ),
              ...intro.topics.map(
                (topic) => Text(
                  '• $topic',
                  style: AppTextStyleNew.body02.value(
                    color: AppColor.black.color,
                  ),
                ),
              ),
            ],
          ),
        if (hasIceBreaker) ...[
          Text(
            'Ice breaker message:',
            style: AppTextStyleNew.body01Bold.value(
              color: AppColor.black.color,
            ),
          ),
          Container(
            padding: EdgeInsets.all(Space.lg.value),
            decoration: BoxDecoration(
              color: AppColor.white.color,
              borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
              border: Border.all(color: AppColor.bgDisabled.color),
            ),
            child: Text(
              intro.iceBreaker,
              style: AppTextStyleNew.body02.value(
                color: AppColor.textDefault.color,
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: intro.iceBreaker));
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: const Text('Copied intro message'),
                  backgroundColor: AppColor.primary.color,
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy message'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary.color,
              backgroundColor: AppColor.white.color,
              side: BorderSide(color: AppColor.bgDisabled.color),
              padding: EdgeInsets.symmetric(
                horizontal: Space.lg.value,
                vertical: Space.sm.value,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
              ),
            ),
          )
        ],
      ],
    );
  }
}

String _formatTimestamp(DateTime time) {
  final local = time.toLocal();
  final twoDigits = (int value) => value.toString().padLeft(2, '0');
  return '${local.year}/${twoDigits(local.month)}/${twoDigits(local.day)} ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

Future<void> _launchUrl(String url) async {
  try {
    var normalized = url.trim();
    if (normalized.isEmpty) return;
    if (!normalized.startsWith('http')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.parse(normalized);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // ignore launch failures
  }
}

String? _profileUrlForPeer(PeerInfo peer) {
  final socialLink = peer.socialLink?.trim();
  if (socialLink != null && socialLink.isNotEmpty) {
    return socialLink.startsWith('http') ? socialLink : 'https://$socialLink';
  }
  final linkedinId = peer.linkedinId?.trim();
  if (linkedinId != null && linkedinId.isNotEmpty) {
    return linkedinId.startsWith('http')
        ? linkedinId
        : 'https://www.linkedin.com/in/$linkedinId';
  }
  return null;
}

