// Angel Daniel Genao 2024-1169
// "Cerebro" de la pantalla de videos: pide la lista al repositorio y
// actualiza VideosState para que la pantalla se redibuje sola.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';
import '../../data/providers/videos_data_providers.dart';
import '../../domain/repositories/videos_repository.dart';
import 'videos_state.dart';

class VideosController extends Notifier<VideosState> {
  late final VideosRepository _repository;

  @override
  VideosState build() {
    _repository = ref.watch(videosRepositoryProvider);
    return VideosState.initial();
  }

  // Carga los videos la primera vez que se abre la pantalla.
  Future<void> loadInitial() async {
    if (state.isInitialLoading) {
      return;
    }

    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final videos = await _repository.getVideos();
      state = state.copyWith(videos: videos, error: null);
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  // "Pull to refresh": vuelve a pedir la lista saltando la caché.
  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final videos = await _repository.getVideos(forceRefresh: true);
      state = state.copyWith(videos: videos, error: null);
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  // Reintenta la carga después de un error (botón "Reintentar").
  Future<void> retry() async {
    state = state.copyWith(isInitialLoading: false, error: null);
    await loadInitial();
  }

  AppException _toAppException(Object error) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: 'Ocurrió un error inesperado.',
      cause: error,
    );
  }
}
