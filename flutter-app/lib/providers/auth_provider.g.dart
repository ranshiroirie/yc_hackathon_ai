// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'82398d9f38c720e4ddf6b218248f15089fd4f178';

/// Provider for AuthService
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$authStateChangesHash() => r'b1726698ea332be89f8752bfd083248ab5294b43';

/// Provider for current Firebase Auth user stream
///
/// Copied from [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'a3c1a250ed54e348b8468a6a83787f08c5b1064a';

/// Provider for current authenticated user
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$authStateStatusHash() => r'160957c7c2dbe8ce4849d22c3201f8107a6d0262';

/// Provider for authentication status
///
/// Copied from [authStateStatus].
@ProviderFor(authStateStatus)
final authStateStatusProvider =
    AutoDisposeStreamProvider<AuthStateStatus>.internal(
      authStateStatus,
      name: r'authStateStatusProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authStateStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateStatusRef = AutoDisposeStreamProviderRef<AuthStateStatus>;
String _$isAuthenticatedHash() => r'ec341d95b490bda54e8278477e26f7b345844931';

/// Provider for checking if user is authenticated
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$anonymousSignInHash() => r'94a2e69f9fbd17e5d37f0660f25f3a4b7ba6e94f';

/// Provider for anonymous sign in
///
/// Copied from [AnonymousSignIn].
@ProviderFor(AnonymousSignIn)
final anonymousSignInProvider =
    AutoDisposeAsyncNotifierProvider<AnonymousSignIn, void>.internal(
      AnonymousSignIn.new,
      name: r'anonymousSignInProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$anonymousSignInHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnonymousSignIn = AutoDisposeAsyncNotifier<void>;
String _$signOutHash() => r'6220d5488ec5ab2eaa2e9b5c43e8ee2b77bc39f5';

/// Provider for sign out
///
/// Copied from [SignOut].
@ProviderFor(SignOut)
final signOutProvider =
    AutoDisposeAsyncNotifierProvider<SignOut, void>.internal(
      SignOut.new,
      name: r'signOutProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product') ? null : _$signOutHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignOut = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
