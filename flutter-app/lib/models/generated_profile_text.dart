class GeneratedProfileText {
  static const String fallbackSource = 'fallback_template';

  final String generatedProfileText;
  final String source;
  final String? templateId;

  const GeneratedProfileText({
    required this.generatedProfileText,
    required this.source,
    this.templateId,
  });

  factory GeneratedProfileText.fromMap(Map<String, dynamic> map) {
    return GeneratedProfileText(
      generatedProfileText:
          (map['generated_profile_text'] as String? ?? '').trim(),
      source: map['source'] as String? ?? 'none',
      templateId: map['template_id'] as String?,
    );
  }

  factory GeneratedProfileText.fallback({
    required String nickname,
    required String linkedinId,
  }) {
    return GeneratedProfileText(
      generatedProfileText: _buildFallbackText(
        nickname: nickname,
        linkedinId: linkedinId,
      ),
      source: fallbackSource,
      templateId: null,
    );
  }

  bool get isFallback => source == fallbackSource;

  Map<String, dynamic> toJson() {
    return {
      'generated_profile_text': generatedProfileText,
      'source': source,
      'template_id': templateId,
    };
  }

  static String _buildFallbackText({
    required String nickname,
    required String linkedinId,
  }) {
    final displayName = nickname.trim().isEmpty ? 'I' : nickname.trim();
    final linkedinUrl = _buildLinkedinUrl(linkedinId);

    final lines = <String>[
      "Hi, I'm $displayName!",
      "- What I'm excited about: collaborating with founders and builders around AI-powered experiences.",
      "- How I can help: sharing quick insights, prototyping ideas, and connecting people.",
      "- What I'm looking for: partners who enjoy learning fast and building bold products together.",
    ];

    return lines.join('\n');
  }

  static String? _buildLinkedinUrl(String rawLinkedinId) {
    final trimmed = rawLinkedinId.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.startsWith('http')) {
      return trimmed;
    }

    final sanitized = trimmed
        .replaceFirst(RegExp(r'^https?:\/\/(www\.)?linkedin\.com\/in\/'), '')
        .replaceFirst(RegExp(r'^linkedin\.com\/in\/'), '')
        .replaceAll(RegExp(r'^\/+'), '')
        .replaceFirst(RegExp(r'^in\/'), '');

    if (sanitized.isEmpty) {
      return null;
    }

    return 'https://www.linkedin.com/in/$sanitized';
  }
}

