import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:homii_ai_event_comp_app/services/functions_service.dart';

part 'functions_provider.g.dart';

/// Provider for FunctionsService
@riverpod
FunctionsService functionsService(Ref ref) {
  return FunctionsService();
}

/// Provider for FirebaseFunctions instance
@riverpod
FirebaseFunctions functions(Ref ref) {
  final service = ref.watch(functionsServiceProvider);
  return service.instance;
}

