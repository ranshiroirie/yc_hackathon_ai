import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/models/profile_input.dart';
import 'package:homii_ai_event_comp_app/providers/auth_provider.dart';
import 'package:homii_ai_event_comp_app/providers/functions_provider.dart';
import 'package:homii_ai_event_comp_app/views/screens/main_screen.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';

/// Personal information - Goals screen
/// User enters their goals
class GoalsScreen extends ConsumerStatefulWidget {
  final String nickname;
  final String linkedinId;
  final String generatedProfileText;
  final int profileImageKey;

  const GoalsScreen({
    super.key,
    required this.nickname,
    required this.linkedinId,
    required this.generatedProfileText,
    required this.profileImageKey,
  });

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalsController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _goalsController.addListener(_validateGoals);
  }

  @override
  void dispose() {
    _goalsController.dispose();
    super.dispose();
  }

  void _validateGoals() {
    setState(() {
      _isValid = _goalsController.text.trim().isNotEmpty;
    });
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify authentication before calling function
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please sign in first'),
              backgroundColor: AppColor.danger.color,
            ),
          );
        }
        return;
      }
      
      final functionsService = ref.read(functionsServiceProvider);
      
      // Prepare profile data
      final profileInput = ProfileInput(
        nickname: widget.nickname,
        linkedinId: widget.linkedinId,
        introduction: _goalsController.text.trim(),
        generatedProfileText: widget.generatedProfileText,
        profileImageKey: widget.profileImageKey,
      );

      await functionsService.profileUpsert(profileInput);
      
      debugPrint('Profile saved successfully');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainScreen(showWelcome: true),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: AppColor.danger.color,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          child: Form(
            key: _formKey,
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

                        Column(
                          spacing: Space.md.value,
                          children: [
                            Text(
                              "Help me understand you better✨",
                              textAlign: TextAlign.center,
                              style: AppTextStyleNew.body01.value(
                                color: AppColor.black.color,
                              ),
                            ),
                            Text(
                              'Share your goals, strengths, and challenges',
                              textAlign: TextAlign.center,
                              style: AppTextStyleNew.heading03.value(
                                color: AppColor.black.color,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppRadius.xxxl.value,
                            ),
                            border: Border.all(color: Colors.white),
                          ),
                          child: TextFormField(
                            controller: _goalsController,
                            decoration: InputDecoration(
                              hintText: "• Why I'm here today...\n• People I'd love to meet...\n• My strengths and challenges...",
                              hintStyle: AppTextStyleNew.body01.value(
                                color: AppColor.gray24.color,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: Space.lg.value,
                                vertical: Space.md.value,
                              ),
                            ),
                            minLines: 6,
                            maxLines: 10,
                            style: AppTextStyleNew.body01.value(
                              color: AppColor.black.color,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(400),
                            ],
                            onFieldSubmitted: (_) => _handleSubmit(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _isValid && !_isLoading ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary.color,
                    foregroundColor: AppColor.white.color,
                    disabledBackgroundColor: AppColor.bgDisabled.color,
                    padding: EdgeInsets.symmetric(vertical: Space.md.value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                    ),
                  ),
                  child: _isLoading ? 
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    )
                    : Text(
                      'Continue',
                      style: AppTextStyleNew.body01Bold.value(
                        color: AppColor.white.color,
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

