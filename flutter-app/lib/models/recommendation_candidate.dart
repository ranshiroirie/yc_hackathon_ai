class RecommendationCandidate {
  final String uid;
  final String nickname;
  final int profileImageKey;
  final double score;
  final String reason;
  final String introduction;
  final String sourceType;

  RecommendationCandidate({
    required this.uid,
    required this.nickname,
    required this.profileImageKey,
    required this.score,
    required this.reason,
    required this.introduction,
    required this.sourceType,
  });

  bool get isPredata => sourceType.toLowerCase() == 'predata';

  factory RecommendationCandidate.fromMap(Map<String, dynamic> map) {
    final rawSource = map['sourceType'] ?? map['source_type'] ?? 'profile';
    return RecommendationCandidate(
      uid: map['uid'] as String? ?? '',
      nickname: map['nickname'] as String? ?? '',
      profileImageKey: (map['profile_image_key'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num?)?.toDouble() ?? 0,
      reason: map['reason'] as String? ?? '',
      introduction: map['introduction'] as String? ?? '',
      sourceType: rawSource is String ? rawSource : 'profile',
    );
  }
}

