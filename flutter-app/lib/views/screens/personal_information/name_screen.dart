import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homii_ai_event_comp_app/constants/app_asset_image.dart';
import 'package:homii_ai_event_comp_app/views/screens/personal_information/social_link_screen.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/core/images/app_asset_image_widget.dart';

/// Personal information - Name screen
/// User enters their nickname
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isValid = _nameController.text.trim().isNotEmpty;
    });
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SocialLinkScreen(nickname: name),
        ),
      );
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
                              "Hi! Lumi here! 👋 I'm here to help you make amazing connections at this event. ",
                              textAlign: TextAlign.center,
                              style: AppTextStyleNew.body01.value(
                                color: AppColor.black.color,
                              ),
                            ),
                            Text(
                              'What’s your name?',
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
                            borderRadius: BorderRadius.circular(AppRadius.xxxl.value),
                            border: Border.all(color: Colors.white),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your nickname',
                              hintStyle: AppTextStyleNew.body01Bold.value(
                                color: AppColor.gray24.color,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: Space.lg.value,
                                vertical: Space.md.value,
                              ),
                            ),
                            style: AppTextStyleNew.body01Bold.value(
                              color: AppColor.black.color,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(32),
                            ],
                            onFieldSubmitted: (_) => _handleNext(),
                          ),
                        ),
                      ],
                    ),
                  )
                ),

                ElevatedButton(
                  onPressed: _isValid ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary.color,
                    foregroundColor: AppColor.white.color,
                    disabledBackgroundColor: AppColor.bgDisabled.color,
                    padding: EdgeInsets.symmetric(
                      vertical: Space.md.value,
                    ),
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

