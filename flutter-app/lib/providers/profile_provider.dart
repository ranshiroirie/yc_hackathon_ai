import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'auth_provider.dart';
import 'firestore_provider.dart';

part 'profile_provider.g.dart';

/// Profile completion status
enum ProfileCompletionStatus {
  notAuthenticated,
  noProfile,
  missingNickname,
  missingIntroduction,
  missingSocialLink,
  complete,
}

/// Provider for user profile document
@riverpod
Stream<DocumentSnapshot<Map<String, dynamic>>?> userProfile(
  Ref ref,
) {
  final currentUser = ref.watch(currentUserProvider);
  final firestore = ref.watch(firestoreProvider);

  if (currentUser == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('hackathon_profiles')
      .doc(currentUser.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? snapshot : null);
}

/// Provider for profile completion status
@riverpod
Stream<ProfileCompletionStatus> profileCompletionStatus(
  Ref ref,
) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUser = ref.watch(currentUserProvider);
  final firestore = ref.watch(firestoreProvider);
  
  if (!isAuthenticated || currentUser == null) {
    return Stream.value(ProfileCompletionStatus.notAuthenticated);
  }

  // Get the stream directly from Firestore
  return firestore
      .collection('hackathon_profiles')
      .doc(currentUser.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      return ProfileCompletionStatus.noProfile;
    }

    final data = snapshot.data();
    if (data == null) {
      return ProfileCompletionStatus.noProfile;
    }

    final nickname = data['nickname'] as String?;
    final introduction = data['introduction'] as String?;
    if (nickname == null || nickname.trim().isEmpty) {
      return ProfileCompletionStatus.missingNickname;
    }

    if (introduction == null || introduction.trim().isEmpty) {
      return ProfileCompletionStatus.missingIntroduction;
    }

    final linkedinId = data['linkedin_id'] as String?;
    if (linkedinId == null || linkedinId.trim().isEmpty) {
      return ProfileCompletionStatus.missingSocialLink;
    }

    return ProfileCompletionStatus.complete;
  });
}

/// Provider for checking if profile is complete (synchronous)
@riverpod
Future<bool> isProfileComplete(Ref ref) async {
  final statusAsync = ref.watch(profileCompletionStatusProvider);
  return statusAsync.when(
    data: (status) => status == ProfileCompletionStatus.complete,
    loading: () => false,
    error: (_, __) => false,
  );
}

