// Angel Daniel Genao 2024-1169
// Describe el estado de la pantalla de videos (loading, lista, error).
// Es el mismo patrón que NewsState.

import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/video.dart';

// Valor "truco" para diferenciar "no tocar el error" de "poner error en null".
const _unset = Object();

class VideosState extends Equatable {
  VideosState({
    required this.isInitialLoading,
    required this.isRefreshing,
    required List<Video> videos,
    required this.error,
  }) : videos = List.unmodifiable(videos);

  factory VideosState.initial() {
    return VideosState(
      isInitialLoading: false,
      isRefreshing: false,
      videos: const [],
      error: null,
    );
  }

  final bool isInitialLoading;
  final bool isRefreshing;
  final List<Video> videos;
  final AppException? error;

  bool get hasError => error != null;
  bool get isEmpty => !isInitialLoading && !isRefreshing && videos.isEmpty;

  VideosState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    List<Video>? videos,
    Object? error = _unset,
  }) {
    return VideosState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      videos: videos ?? this.videos,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [isInitialLoading, isRefreshing, videos, error];
}
