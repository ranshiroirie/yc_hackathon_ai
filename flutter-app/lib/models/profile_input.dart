class ProfileInput {
  final String nickname;
  final String linkedinId;
  final String introduction;
  final String generatedProfileText;
  final int profileImageKey;

  ProfileInput({
    required this.nickname,
    required this.linkedinId,
    required this.introduction,
    required this.generatedProfileText,
    required this.profileImageKey,
  });

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'linkedin_id': linkedinId,
        'introduction': introduction,
        'generated_profile_text': generatedProfileText,
        'profile_image_key': profileImageKey,
      };
}

