import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/providers/functions_provider.dart';
import 'package:homii_ai_event_comp_app/services/functions_service.dart';
import 'package:homii_ai_event_comp_app/views/screens/personal_information/self_intro_screen.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';

/// Personal information - Social link screen
/// User enters their social link
class SocialLinkScreen extends ConsumerStatefulWidget {
  final String nickname;

  const SocialLinkScreen({
    super.key,
    required this.nickname,
  });

  @override
  ConsumerState<SocialLinkScreen> createState() => _SocialLinkScreenState();
}

class _SocialLinkScreenState extends ConsumerState<SocialLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkedinIdController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _linkedinIdController.addListener(_validateSocialLink);
  }

  @override
  void dispose() {
    _linkedinIdController.dispose();
    super.dispose();
  }

  void _validateSocialLink() {
    setState(() {
      _isValid = _linkedinIdController.text.trim().isNotEmpty;
    });
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final functionsService = ref.read(functionsServiceProvider);
      final nickname = widget.nickname.trim();
      final linkedinId = _linkedinIdController.text.trim();

      final generatedProfile =
          await functionsService.generateProfileText(
        nickname: nickname,
        linkedinId: linkedinId,
      );

      final int profileImageKey =
          1 + (DateTime.now().millisecondsSinceEpoch % 10);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SelfIntroScreen(
              nickname: widget.nickname,
              linkedinId: linkedinId,
              generatedProfileText:
                  generatedProfile.generatedProfileText,
              profileImageKey: profileImageKey,
            ),
          ),
        );
      }
    } on FunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColor.danger.color,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate profile. Please try again.'),
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
          child: _isLoading 
            ? Center(
              child: Column(
                spacing: Space.xl.value,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: AppAssetImageWidget(
                      appAssetImage: AppAssetImage.lumii,
                    ),
                  ),

                  Text(
                    "Generating your profile...",
                    textAlign: TextAlign.center,
                    style: AppTextStyleNew.heading03.value(
                      color: AppColor.black.color,
                    ),
                  ),
                ],
              ),
            )
            : Form(
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
                                "Nice to meet you, ${widget.nickname}! The more I know, the better connections I can make! ✨",
                                textAlign: TextAlign.center,
                                style: AppTextStyleNew.body01.value(
                                  color: AppColor.black.color,
                                ),
                              ),
                              Text(
                                "What's your LinkedIn?",
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
                              controller: _linkedinIdController,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: Space.lg.value, right: 4.0),
                                  child: Text(
                                    'linkedin.com/in/',
                                    style: AppTextStyleNew.body01.value(
                                      color: AppColor.gray60.color,
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                hintText: 'your-profile',
                                hintStyle: AppTextStyleNew.body01.value(
                                  color: AppColor.gray24.color,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: Space.md.value,
                                ),
                              ),
                              style: AppTextStyleNew.body01.value(
                                color: AppColor.black.color,
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(200),
                              ],
                              onFieldSubmitted: (_) => _handleNext(),
                            ),
                          ),
                        ],
                      ),
                    )
                  ),

                  ElevatedButton(
                    onPressed: _isValid && !_isLoading ? _handleNext : null,
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
              ),
            ),
        ),
      ),
    );
  }
}

