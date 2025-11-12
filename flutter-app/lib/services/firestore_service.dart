import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore service for handling database operations
/// Follows Clean Architecture principles
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Firestore instance
  FirebaseFirestore get instance => _firestore;

  /// Get a collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a document reference
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  /// Get a document snapshot
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(String path) async {
    return await _firestore.doc(path).get();
  }

  /// Set a document
  Future<void> setDoc(
    String path,
    Map<String, dynamic> data, {
    SetOptions? options,
  }) async {
    return await _firestore.doc(path).set(data, options);
  }

  /// Update a document
  Future<void> updateDoc(
    String path,
    Map<String, dynamic> data,
  ) async {
    return await _firestore.doc(path).update(data);
  }

  /// Delete a document
  Future<void> deleteDoc(String path) async {
    return await _firestore.doc(path).delete();
  }

  /// Get a collection stream
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(String path) {
    return _firestore.collection(path).snapshots();
  }

  /// Get a document stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> docStream(String path) {
    return _firestore.doc(path).snapshots();
  }

  /// Query a collection
  Query<Map<String, dynamic>> queryCollection(String path) {
    return _firestore.collection(path);
  }
}

