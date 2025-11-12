import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homii_ai_event_comp_app/firebase_options.dart';
import 'package:homii_ai_event_comp_app/models/generated_profile_text.dart';
import 'package:homii_ai_event_comp_app/models/profile_input.dart';
import 'package:homii_ai_event_comp_app/models/recommendation_candidate.dart';

/// Firebase Functions service for handling callable functions
/// Follows Clean Architecture principles with proper error handling
class FunctionsService {
  /// Get Functions instance
  FirebaseFunctions get instance => DefaultFirebaseOptions.functions;

  /// Call a callable function
  /// 
  /// [functionName] - Name of the callable function
  /// [data] - Optional data to pass to the function
  /// Returns the result from the function
  /// Throws [FunctionsException] if the call fails
  Future<HttpsCallableResult<dynamic>> callFunction(
    String functionName, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // Verify user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw FunctionsException(
          code: 'unauthenticated',
          message: 'User must be authenticated to call functions',
        );
      }
      
      final callable = instance.httpsCallable(functionName);
      
      // The auth token is automatically included by Firebase SDK
      // when the user is authenticated. For emulators, this should work automatically.
      final result = await callable.call(data ?? {});
      
      debugPrint('Function $functionName completed successfully');
      return result;
    } on FirebaseFunctionsException catch (e) {
      // Log detailed error for debugging
      debugPrint('Functions error: code=${e.code}, message=${e.message}, details=${e.details}');
      throw _handleFunctionsException(e);
    } catch (e) {
      debugPrint('Unexpected error calling function: $e');
      throw FunctionsException(
        code: 'unknown_error',
        message: 'An unexpected error occurred while calling the function',
        originalError: e,
      );
    }
  }

  /// Call generateProfileText function
  Future<GeneratedProfileText> generateProfileText({
    required String nickname,
    required String linkedinId,
  }) async {
    try {
      final result = await callFunction(
        'generateProfileText',
        data: {
          'nickname': nickname,
          'linkedin_id': linkedinId,
        },
      );

      final response = result.data;
      Map<String, dynamic>? responseMap;
      if (response is Map<String, dynamic>) {
        responseMap = response;
      } else if (response is Map) {
        responseMap = Map<String, dynamic>.from(response);
      }

      if (responseMap == null) {
        debugPrint(
          'generateProfileText returned unexpected response type: '
          '${response.runtimeType}',
        );
        return GeneratedProfileText.fallback(
          nickname: nickname,
          linkedinId: linkedinId,
        );
      }

      final generatedText = responseMap['generated_profile_text'];
      if (generatedText is! String || generatedText.trim().isEmpty) {
        debugPrint(
          'generateProfileText missing generated_profile_text: $responseMap',
        );
        return GeneratedProfileText.fallback(
          nickname: nickname,
          linkedinId: linkedinId,
        );
      }

      return GeneratedProfileText.fromMap(responseMap);
    } on FunctionsException catch (e) {
      if (e.code == 'unauthenticated' || e.code == 'permission-denied') {
        rethrow;
      }
      debugPrint(
        'generateProfileText FunctionsException (fallback applied): '
        'code=${e.code}, message=${e.message}',
      );
      return GeneratedProfileText.fallback(
        nickname: nickname,
        linkedinId: linkedinId,
      );
    } catch (e) {
      debugPrint('generateProfileText unexpected error: $e');
      return GeneratedProfileText.fallback(
        nickname: nickname,
        linkedinId: linkedinId,
      );
    }
  }

  /// Call profileUpsert function
  Future<void> profileUpsert(ProfileInput input) async {
    await callFunction('profileUpsert', data: input.toJson());
  }

  /// Call joinEvent function
  Future<Map<String, dynamic>> joinEvent() async {
    final result = await callFunction('joinEvent');
    final data = result.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  /// Call getRecommendations function
  Future<List<RecommendationCandidate>> getRecommendations({int limit = 3}) async {
    final result = await callFunction(
      'getRecommendations',
      data: {'limit': limit},
    );
    final response = result.data;
    if (response is Map<String, dynamic>) {
      final candidates = response['candidates'] as List<dynamic>? ?? [];
      return candidates.map((candidate) {
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
    }
    return [];
  }

  /// Call listParticipants function
  Future<Map<String, dynamic>> listParticipants({
    int? limit,
    String? cursor,
  }) async {
    final data = <String, dynamic>{};
    if (limit != null) data['limit'] = limit;
    if (cursor != null) data['cursor'] = cursor;
    final result = await callFunction('listParticipants', data: data);
    final response = result.data;
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return {};
  }

  /// Call proposeConnection function
  Future<Map<String, dynamic>> proposeConnection({
    required String toUid,
    String? note,
  }) async {
    final data = <String, dynamic>{'toUid': toUid};
    if (note != null) data['note'] = note;
    final result = await callFunction('proposeConnection', data: data);
    final response = result.data;
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return {};
  }

  /// Call respondConnection function
  Future<Map<String, dynamic>> respondConnection({
    required String fromUid,
    required bool accept,
    String? replyReason,
  }) async {
    final data = <String, dynamic>{
      'fromUid': fromUid,
      'accept': accept,
    };
    if (replyReason != null) data['reply_reason'] = replyReason;
    final result = await callFunction('respondConnection', data: data);
    final response = result.data;
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return {};
  }

  /// Handle Firebase Functions exceptions and convert to user-friendly messages
  FunctionsException _handleFunctionsException(FirebaseFunctionsException e) {
    String userMessage;

    switch (e.code) {
      case 'unauthenticated':
        userMessage = 'Authentication required. Please sign in.';
        break;
      case 'permission-denied':
        userMessage = 'Permission denied. You do not have access to this function.';
        break;
      case 'invalid-argument':
        userMessage = 'Invalid arguments provided. Please check your input.';
        break;
      case 'not-found':
        userMessage = 'Function not found. Please contact support.';
        break;
      case 'internal':
        userMessage = 'An internal error occurred. Please try again later.';
        break;
      case 'unavailable':
        userMessage = 'Service is temporarily unavailable. Please try again later.';
        break;
      case 'deadline-exceeded':
        userMessage = 'Request timed out. Please try again.';
        break;
      default:
        userMessage = e.message ?? 'An error occurred while calling the function.';
    }

    return FunctionsException(
      code: e.code,
      message: userMessage,
      originalError: e,
    );
  }
}

/// Custom exception class for Firebase Functions errors
/// Provides user-friendly error messages
class FunctionsException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;

  FunctionsException({
    required this.code,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => message;
}

