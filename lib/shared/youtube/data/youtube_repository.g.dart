// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(youtubeRepository)
final youtubeRepositoryProvider = YoutubeRepositoryProvider._();

final class YoutubeRepositoryProvider
    extends
        $FunctionalProvider<
          YoutubeRepository,
          YoutubeRepository,
          YoutubeRepository
        >
    with $Provider<YoutubeRepository> {
  YoutubeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'youtubeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$youtubeRepositoryHash();

  @$internal
  @override
  $ProviderElement<YoutubeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  YoutubeRepository create(Ref ref) {
    return youtubeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YoutubeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YoutubeRepository>(value),
    );
  }
}

String _$youtubeRepositoryHash() => r'3ad850b93025a7bf08d05d8c137e1abb93afe92f';
