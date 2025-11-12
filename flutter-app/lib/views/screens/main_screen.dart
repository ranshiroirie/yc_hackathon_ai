import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/user_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_lottie.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/providers/ai_message_provider.dart';
import 'package:homii_ai_event_comp_app/providers/participants_provider.dart';
import 'package:homii_ai_event_comp_app/models/ai_message.dart';
import 'package:homii_ai_event_comp_app/views/widgets/chat/chat_bubble.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/lottie/app_asset_lottie_widget.dart';
import 'package:homii_ai_event_comp_app/views/widgets/ai_messages/ai_messages_timeline_modal.dart';

class BubbleState {
  bool isShowed;
  String title;
  String message;

  BubbleState({
    this.isShowed = false,
    this.title = '',
    this.message = '',
  });
}

/// Main screen - Home screen after profile setup
class MainScreen extends ConsumerStatefulWidget {
  /// When true, shows the Lumi welcome bubble on first render
  final bool showWelcome;

  const MainScreen({
    super.key,
    this.showWelcome = false
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _processedMessageIds = {};

  bool _showWelcome = false;
  BubbleState _bubbleState = BubbleState();
  List<AiMessage> _aiMessages = [];

  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    _showWelcome = widget.showWelcome;
    _bubbleState = BubbleState(
      isShowed: widget.showWelcome,
      title: 'All set! 🎉',
      message: "I'll let you know when I find someone you should meet! ✨",
    );

    // Initialize animation controller
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create slide-up animation (0 = bottom, 1 = top)
    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutCubic,
    );

    // Start animation if bubble should be shown
    if (_bubbleState.isShowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bubbleController.forward().then((_) {
          // Start 5-second timer after animation completes
          _autoCloseTimer = Timer(const Duration(seconds: 5), () {
            _closeBubble();
          });
        });
      });
    }

    if (_showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(const Duration(seconds: 2), () {
          _showWelcome = false;
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialMessages = ref.read(aiMessagesProvider);
      initialMessages.whenData((messages) {
        if (!mounted) return;
        setState(() {
          _aiMessages = messages;
        });
        _processNextMessage(messages);
      });
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _closeBubble() {
    if (!mounted) return;
    _autoCloseTimer?.cancel();
    _bubbleController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _bubbleState.isShowed = false;
        });
      }
    });
  }

  void _processNextMessage(List<AiMessage> messages) {
    AiMessage? nextMessage;
    for (final message in messages) {
      if (!_processedMessageIds.contains(message.id)) {
        nextMessage = message;
        break;
      }
    }
    if (nextMessage != null) {
      _handleNewMessage(nextMessage, context);
    }
  }

  void _handleNewMessage(AiMessage message, BuildContext context) {
    // Skip if already processed
    if (_processedMessageIds.contains(message.id)) {
      return;
    }
    _processedMessageIds.add(message.id);

    // Store latest message for modal display and update UI
    setState(() {
      switch (message.type) {
        case AiMessageType.foundMatch:
          _bubbleState = BubbleState(
            isShowed: true,
            title: 'I found your match! ✨',
            message: '',
          );
          break;
        case AiMessageType.requestMatch:
          _bubbleState = BubbleState(
            isShowed: true,
            title: 'Someone wants to connect with you! 🎉',
            message: '',
          );
          break;
        case AiMessageType.matchIntro:
          _bubbleState = BubbleState(
            isShowed: true,
            title: 'It’s a match! 🎉',
            message: 'Tap Lumi to see the intro message.',
          );
          break;
      }
    });

    _bubbleController.forward(from: 0);
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 5), _closeBubble);
  }

  void _showModal() {
    if (_aiMessages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No AI messages yet'),
            backgroundColor: AppColor.primary.color,
          ),
        );
      }
      return;
    }

    AiMessagesTimelineModal.show(
      context,
      messages: _aiMessages,
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final appUri = Uri.parse(url);
      await launchUrl(appUri);
    } catch (e) {
      debugPrint('Failed to open URL - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<AiMessage>>>(
      aiMessagesProvider,
      (previous, next) {
        next.whenData((messages) {
          if (!mounted) return;
          setState(() {
            _aiMessages = messages;
          });
          _processNextMessage(messages);
        });
      },
    );

    return Scaffold(
      backgroundColor: AppColor.bgBeige.color,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showWelcome)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: AppAssetLottieWidget(
                        assetPath: AppAssetLottie.confetti.lottiePath,
                        fit: BoxFit.cover,
                        repeat: false,
                      ),
                    ),
                    Transform.scale(
                      scale: 1.5,
                      child: AppAssetLottieWidget(
                        assetPath: AppAssetLottie.confetti.lottiePath,
                        fit: BoxFit.cover,
                        repeat: false,
                      ),
                    ),
                  ],
                ),
              ),

            // Content column behind
            Padding(
              padding: EdgeInsets.all(Space.xl.value),
              child: Column(
                spacing: Space.xl.value,
                children: [
                  // Header with event name (hardcoded)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Space.md.value,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: [AppBoxShadow.shadowMD.value],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AppAssetImageWidget(
                            appAssetImage: AppAssetImage.event,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Space.xs.value,
                          children: [
                            Text(
                              'VIBE25-5: Welcome to San Fransokyo',
                              style: AppTextStyleNew.heading04.value(
                                color: AppColor.black.color,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                _launchUrl('https://luma.com/whkm8jf2?tk=Ied2kk');
                              },
                              child: Text(
                                'https://luma.com/whkm8jf2?tk=Ied2kk',
                                style: AppTextStyleNew.body02.value(
                                  color: Color(0xFF3B95BA),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  // Participants list
                  Expanded(
                    child: _buildParticipantsList(ref),
                  ),
                ],
              ),
            ),

            // Lumi image at bottom center
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Space.defaultt.value,
                children: [
                  // Animated bubble that slides up from bottom
                  if (_bubbleState.isShowed)
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1.5), // Start below (hidden)
                        end: Offset.zero, // End at normal position
                      ).animate(_bubbleAnimation),
                      child: FadeTransition(
                        opacity: _bubbleAnimation,
                        child: ChatBubble(
                          title: _bubbleState.title,
                          message: _bubbleState.message,
                          onTap: _closeBubble,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),

                  GestureDetector(
                    onTap: () {
                      // Show appropriate modal based on latest message
                      _showModal();
                    },
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: AppAssetImageWidget(
                        appAssetImage: AppAssetImage.lumii,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsList(WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider(limit: 50));

    return participantsAsync.when(
      data: (participants) {
        if (participants.isEmpty) {
          return Center(
            child: Text(
              'No participants yet',
              style: AppTextStyleNew.body02.value(
                color: AppColor.textSecondary.color,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: Space.x3s.value),
          separatorBuilder: (context, index) => SizedBox(height: Space.defaultt.value),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return _ParticipantListItem(participant: participant);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading participants: ${error.toString()}',
          style: AppTextStyleNew.body02.value(
            color: AppColor.danger.color,
          ),
        ),
      ),
    );
  }
}

class _ParticipantListItem extends StatelessWidget {
  final Participant participant;

  const _ParticipantListItem({
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Space.defaultt.value,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.primary.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: UserAvatar(imageKey: participant.profileImageKey),
          ),
        ),

        Text(
          participant.nickname,
          style: AppTextStyleNew.body01.value(
            color: AppColor.black.color,
          ),
        ),
      ],
    );
  }
}
