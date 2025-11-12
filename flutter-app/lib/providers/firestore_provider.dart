import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:homii_ai_event_comp_app/services/firestore_service.dart';

part 'firestore_provider.g.dart';

/// Provider for FirestoreService
@riverpod
FirestoreService firestoreService(Ref ref) {
  return FirestoreService();
}

/// Provider for FirebaseFirestore instance
@riverpod
FirebaseFirestore firestore(Ref ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.instance;
}

