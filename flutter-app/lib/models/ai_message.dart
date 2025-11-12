import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homii_ai_event_comp_app/models/ai_message_type.dart';
import 'package:homii_ai_event_comp_app/models/recommendation_candidate.dart';
import 'package:homii_ai_event_comp_app/utils/string_matching.dart';

export 'ai_message_type.dart';

/// AI Message model
class AiMessage {
  final String id;
  final AiMessageType type;
  final bool isCopiable;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  AiMessage({
    required this.id,
    required this.type,
    required this.isCopiable,
    required this.createdAt,
    required this.payload,
  });

  /// Parse from Firestore document
  factory AiMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final typeStr = data['type'] as String? ?? 'FOUND_MATCH';
    final type = typeFromString(typeStr);

    final timestamp = data['created_at'] as Timestamp?;
    final createdAt = timestamp?.toDate() ?? DateTime.now();

    return AiMessage(
      id: doc.id,
      type: type,
      isCopiable: data['isCopiable'] as bool? ?? false,
      createdAt: createdAt,
      payload: data,
    );
  }

  /// Get candidates for FOUND_MATCH
  List<RecommendationCandidate> get candidates {
    if (type != AiMessageType.foundMatch) {
      return [];
    }
    final candidatesList = payload['candidates'] as List<dynamic>? ?? [];
    final rawCandidates = candidatesList.map((candidate) {
      if (candidate is Map<String, dynamic>) {
        return RecommendationCandidate.fromMap(candidate);
      }
      if (candidate is Map) {
        return RecommendationCandidate.fromMap(
          Map<String, dynamic>.from(candidate),
        );
      }
      return RecommendationCandidate.fromMap({});
    }).toList();

    final filteredCandidates = <RecommendationCandidate>[];
    final normalizedNicknames = <String>[];

    for (final candidate in rawCandidates) {
      final normalizedNickname = normalizeNickname(candidate.nickname);
      if (normalizedNickname.isNotEmpty &&
          hasPartialMatch(normalizedNicknames, normalizedNickname)) {
        continue;
      }
      filteredCandidates.add(candidate);
      if (normalizedNickname.isNotEmpty) {
        normalizedNicknames.add(normalizedNickname);
      }
    }

    return filteredCandidates;
  }

  /// Get request data for REQUEST_MATCH
  RequestMatchData? get requestMatchData {
    if (type != AiMessageType.requestMatch) {
      return null;
    }
    return RequestMatchData.fromMap(Map<String, dynamic>.from(payload));
  }

  /// Get intro data for MATCH_INTRO
  MatchIntroData? get matchIntroData {
    if (type != AiMessageType.matchIntro) {
      return null;
    }
    final intro = payload['intro'];
    if (intro is Map<String, dynamic>) {
      return MatchIntroData.fromMap(intro);
    }
    if (intro is Map) {
      return MatchIntroData.fromMap(Map<String, dynamic>.from(intro));
    }
    return null;
  }
}

/// Request match data (for REQUEST_MATCH)
class RequestMatchData {
  final String fromUid;
  final RecommendationCandidate candidate;
  final String reason;

  RequestMatchData({
    required this.fromUid,
    required this.candidate,
    required this.reason,
  });

  factory RequestMatchData.fromMap(Map<String, dynamic> map) {
    final candidateRaw = map['candidate'];
    final candidateMap = candidateRaw is Map<String, dynamic>
        ? candidateRaw
        : candidateRaw is Map
            ? Map<String, dynamic>.from(candidateRaw)
            : <String, dynamic>{};
    return RequestMatchData(
      fromUid: map['fromUid'] as String? ?? map['from_uid'] as String? ?? '',
      candidate: RecommendationCandidate.fromMap(candidateMap),
      reason: map['reason'] as String? ?? '',
    );
  }
}

/// Match intro data (for MATCH_INTRO)
class MatchIntroData {
  final PeerInfo peer;
  final List<String> topics;
  final String iceBreaker;

  MatchIntroData({
    required this.peer,
    required this.topics,
    required this.iceBreaker,
  });

  factory MatchIntroData.fromMap(Map<String, dynamic> map) {
    final peerMap = map['peer'] as Map<String, dynamic>? ?? {};
    final topicsList = map['topics'] as List<dynamic>? ?? [];
    return MatchIntroData(
      peer: PeerInfo.fromMap(
        peerMap.isEmpty && map['peer'] is Map
            ? Map<String, dynamic>.from(map['peer'])
            : peerMap,
      ),
      topics: topicsList.map((t) => t.toString()).toList(),
      iceBreaker: map['ice_breaker'] as String? ?? '',
    );
  }
}

/// Peer information
class PeerInfo {
  final String uid;
  final String nickname;
  final int profileImageKey;
  final String? socialLink;
  final String? introduction;
  final String? linkedinId;
  final String? generatedProfileText;

  PeerInfo({
    required this.uid,
    required this.nickname,
    required this.profileImageKey,
    this.socialLink,
    this.introduction,
    this.linkedinId,
    this.generatedProfileText,
  });

  factory PeerInfo.fromMap(Map<String, dynamic> map) {
    return PeerInfo(
      uid: map['uid'] as String? ?? '',
      nickname: map['nickname'] as String? ?? '',
      profileImageKey: (map['profile_image_key'] as num?)?.toInt() ?? 0,
      socialLink: map['social_link'] as String?,
      introduction: map['introduction'] as String?,
      linkedinId: map['linkedin_id'] as String?,
      generatedProfileText: map['generated_profile_text'] as String?,
    );
  }
}

