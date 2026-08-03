// Angel Daniel Genao 2024-1169
// Este archivo es el "cerebro" de la pantalla de noticias: decide cuándo pedir
// datos al repositorio, y va actualizando el NewsState para que la pantalla
// se redibuje sola (loading -> datos u error).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';
import '../../data/providers/news_data_providers.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_state.dart';

class NewsController extends Notifier<NewsState> {
  late final NewsRepository _repository;

  // Se ejecuta una sola vez al crear el controlador: guarda el repositorio
  // y devuelve el estado inicial (vacío).
  @override
  NewsState build() {
    _repository = ref.watch(newsRepositoryProvider);
    return NewsState.initial();
  }

  // Carga las noticias la primera vez que se abre la pantalla.
  Future<void> loadInitial() async {
    if (state.isInitialLoading) {
      return;
    }

    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final items = await _repository.getNews();
      state = state.copyWith(items: items, error: null);
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  // Vuelve a pedir las noticias cuando el usuario hace "pull to refresh".
  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      // "forceRefresh" salta la caché: el usuario pidió explícitamente
      // recargar, así que se busca de nuevo aunque el caché siga vigente.
      final items = await _repository.getNews(forceRefresh: true);
      state = state.copyWith(items: items, error: null);
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  // Reintenta la carga inicial después de un error (botón "Reintentar").
  Future<void> retry() async {
    state = state.copyWith(isInitialLoading: false, error: null);
    await loadInitial();
  }

  // Convierte cualquier error inesperado en un AppException conocido,
  // para que la pantalla siempre pueda mostrar un mensaje controlado.
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
