// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_pagination_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(YoutubePagination)
final youtubePaginationProvider = YoutubePaginationFamily._();

final class YoutubePaginationProvider
    extends $AsyncNotifierProvider<YoutubePagination, List<Video>> {
  YoutubePaginationProvider._({
    required YoutubePaginationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'youtubePaginationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$youtubePaginationHash();

  @override
  String toString() {
    return r'youtubePaginationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  YoutubePagination create() => YoutubePagination();

  @override
  bool operator ==(Object other) {
    return other is YoutubePaginationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$youtubePaginationHash() => r'2496c5bcb37abde96b0a616135c3ea736fa17537';

final class YoutubePaginationFamily extends $Family
    with
        $ClassFamilyOverride<
          YoutubePagination,
          AsyncValue<List<Video>>,
          List<Video>,
          FutureOr<List<Video>>,
          String
        > {
  YoutubePaginationFamily._()
    : super(
        retry: null,
        name: r'youtubePaginationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YoutubePaginationProvider call(String playlistId) =>
      YoutubePaginationProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'youtubePaginationProvider';
}

abstract class _$YoutubePagination extends $AsyncNotifier<List<Video>> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  FutureOr<List<Video>> build(String playlistId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Video>>, List<Video>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Video>>, List<Video>>,
              AsyncValue<List<Video>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
