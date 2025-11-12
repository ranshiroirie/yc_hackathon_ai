import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import '../models/ai_message.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

part 'ai_message_provider.g.dart';

/// Provider for AI messages stream
@riverpod
Stream<List<AiMessage>> aiMessages(Ref ref) {
  final currentUser = ref.watch(currentUserProvider);
  final firestore = ref.watch(firestoreProvider);

  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('ai_messages')
      .doc(currentUser.uid)
      .collection('messages')
      .orderBy('created_at', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => AiMessage.fromDoc(doc))
        .toList();
  });
}

