// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileHash() => r'947890baf99bffa4d9f37e5a505b8a0b673f3c1d';

/// Provider for user profile document
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
final userProfileProvider =
    AutoDisposeStreamProvider<DocumentSnapshot<Map<String, dynamic>>?>.internal(
      userProfile,
      name: r'userProfileProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$userProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef =
    AutoDisposeStreamProviderRef<DocumentSnapshot<Map<String, dynamic>>?>;
String _$profileCompletionStatusHash() =>
    r'af8364e5a0f2646132a0a7d6c1c3a08ebab767da';

/// Provider for profile completion status
///
/// Copied from [profileCompletionStatus].
@ProviderFor(profileCompletionStatus)
final profileCompletionStatusProvider =
    AutoDisposeStreamProvider<ProfileCompletionStatus>.internal(
      profileCompletionStatus,
      name: r'profileCompletionStatusProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$profileCompletionStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileCompletionStatusRef =
    AutoDisposeStreamProviderRef<ProfileCompletionStatus>;
String _$isProfileCompleteHash() => r'9a17a9b5c8b357f433046f52e2033f4743a78467';

/// Provider for checking if profile is complete (synchronous)
///
/// Copied from [isProfileComplete].
@ProviderFor(isProfileComplete)
final isProfileCompleteProvider = AutoDisposeFutureProvider<bool>.internal(
  isProfileComplete,
  name: r'isProfileCompleteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isProfileCompleteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsProfileCompleteRef = AutoDisposeFutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
