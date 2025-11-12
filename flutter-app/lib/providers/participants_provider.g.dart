// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participants_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$participantsHash() => r'd5b0fe5a267a8a670c976aa9d6c7e8a24b2b1e11';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for participants list from Firestore
///
/// Copied from [participants].
@ProviderFor(participants)
const participantsProvider = ParticipantsFamily();

/// Provider for participants list from Firestore
///
/// Copied from [participants].
class ParticipantsFamily extends Family<AsyncValue<List<Participant>>> {
  /// Provider for participants list from Firestore
  ///
  /// Copied from [participants].
  const ParticipantsFamily();

  /// Provider for participants list from Firestore
  ///
  /// Copied from [participants].
  ParticipantsProvider call({int limit = 50}) {
    return ParticipantsProvider(limit: limit);
  }

  @override
  ParticipantsProvider getProviderOverride(
    covariant ParticipantsProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'participantsProvider';
}

/// Provider for participants list from Firestore
///
/// Copied from [participants].
class ParticipantsProvider
    extends AutoDisposeStreamProvider<List<Participant>> {
  /// Provider for participants list from Firestore
  ///
  /// Copied from [participants].
  ParticipantsProvider({int limit = 50})
    : this._internal(
        (ref) => participants(ref as ParticipantsRef, limit: limit),
        from: participantsProvider,
        name: r'participantsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$participantsHash,
        dependencies: ParticipantsFamily._dependencies,
        allTransitiveDependencies:
            ParticipantsFamily._allTransitiveDependencies,
        limit: limit,
      );

  ParticipantsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    Stream<List<Participant>> Function(ParticipantsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ParticipantsProvider._internal(
        (ref) => create(ref as ParticipantsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Participant>> createElement() {
    return _ParticipantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ParticipantsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ParticipantsRef on AutoDisposeStreamProviderRef<List<Participant>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _ParticipantsProviderElement
    extends AutoDisposeStreamProviderElement<List<Participant>>
    with ParticipantsRef {
  _ParticipantsProviderElement(super.provider);

  @override
  int get limit => (origin as ParticipantsProvider).limit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
