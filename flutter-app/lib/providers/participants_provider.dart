import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:homii_ai_event_comp_app/utils/string_matching.dart';
import 'firestore_provider.dart';

part 'participants_provider.g.dart';

enum ParticipantSource {
  profile,
  predata,
}

/// Participant data model
class Participant {
  final String uid;
  final String nickname;
  final int profileImageKey;
  final ParticipantSource source;
  final String? linkedinVanity;

  Participant({
    required this.uid,
    required this.nickname,
    required this.profileImageKey,
    this.source = ParticipantSource.profile,
    this.linkedinVanity,
  });

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      uid: map['uid'] as String? ?? '',
      nickname: map['nickname'] as String? ?? '',
      profileImageKey: map['profile_image_key'] as int? ?? 0,
      source: ParticipantSource.profile,
      linkedinVanity: map['linkedin_id'] as String?,
    );
  }

  factory Participant.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Participant(
      uid: doc.id,
      nickname: data['nickname'] as String? ?? '',
      profileImageKey: data['profile_image_key'] as int? ?? 0,
      source: ParticipantSource.profile,
      linkedinVanity: data['linkedin_id'] as String?,
    );
  }

  factory Participant.fromPredataDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Participant(
      uid: 'predata_${doc.id}',
      nickname: data['username'] as String? ?? '',
      profileImageKey: _generateImageKeyFromId(doc.id),
      source: ParticipantSource.predata,
      linkedinVanity: data['linkedin'] as String?,
    );
  }
}

/// Provider for participants list from Firestore
@riverpod
Stream<List<Participant>> participants(Ref ref, {int limit = 50}) {
  final firestore = ref.watch(firestoreProvider);

  final profilesQuery = firestore
      .collection('hackathon_profiles')
      .orderBy('updated_at', descending: true)
      .limit(limit);

  final predataCollection = firestore.collection('hackathon_profile_predata');

  return profilesQuery.snapshots().asyncMap((snapshot) async {
    final participants = snapshot.docs.map(Participant.fromDoc).toList();

    final normalizedNicknames = <String>[];
    final normalizedLinkedins = <String>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final nickname = data['nickname'] as String? ?? '';
      final linkedinId = data['linkedin_id'] as String? ?? '';

      final normalizedNickname = normalizeNickname(nickname);
      if (normalizedNickname.isNotEmpty) {
        normalizedNicknames.add(normalizedNickname);
      }

      final normalizedLinkedin = _normalizeLinkedin(linkedinId);
      if (normalizedLinkedin.isNotEmpty) {
        normalizedLinkedins.add(normalizedLinkedin);
      }
    }

    final predataSnapshot = await predataCollection.get();
    final predataParticipants = <Participant>[];

    for (final doc in predataSnapshot.docs) {
      final data = doc.data();
      final username = data['username'] as String? ?? '';
      final linkedin = data['linkedin'] as String? ?? '';

      final normalizedUsername = normalizeNickname(username);
      final normalizedLinkedin = _normalizeLinkedin(linkedin);

      if (normalizedUsername.isNotEmpty &&
          hasPartialMatch(normalizedNicknames, normalizedUsername)) {
        continue;
      }

      if (normalizedLinkedin.isNotEmpty &&
          hasPartialMatch(normalizedLinkedins, normalizedLinkedin)) {
        continue;
      }

      predataParticipants.add(Participant.fromPredataDoc(doc));
    }

    predataParticipants.sort((a, b) => a.nickname.compareTo(b.nickname));

    if (participants.length >= limit) {
      return participants;
    }

    final remainingSlots = limit - participants.length;
    return [
      ...participants,
      ...predataParticipants.take(remainingSlots),
    ];
  });
}

String _normalizeLinkedin(String value) {
  var normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) {
    return '';
  }

  normalized = normalized.replaceFirst(RegExp(r'^https?://'), '');
  normalized = normalized.replaceFirst(RegExp(r'^(www\.)?linkedin\.com/in/'), '');
  normalized = normalized.replaceFirst(RegExp(r'^(www\.)?linkedin\.com/'), '');
  normalized = normalized.replaceFirst(RegExp(r'^in/'), '');
  normalized = normalized.replaceAll(RegExp(r'/+$'), '');

  return normalized;
}

int _generateImageKeyFromId(String id) {
  final hash = id.hashCode & 0x7fffffff;
  return (hash % 10) + 1;
}
