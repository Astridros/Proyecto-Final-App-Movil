// Angel Daniel Genao 2024-1169
// Este archivo describe "el estado" de la pantalla de noticias: qué se está
// cargando, qué noticias hay y si hubo error. La pantalla solo lee este estado
// para decidir qué mostrar (loading, error, lista vacía o lista con datos).

import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/news_item.dart';

// Valor "truco" para poder distinguir entre "no cambiar el error" y "poner error en null".
const _unset = Object();

class NewsState extends Equatable {
  NewsState({
    required this.isInitialLoading,
    required this.isRefreshing,
    required List<NewsItem> items,
    required this.error,
  }) : items = List.unmodifiable(items);

  // Estado inicial: nada cargando, lista vacía, sin error.
  factory NewsState.initial() {
    return NewsState(
      isInitialLoading: false,
      isRefreshing: false,
      items: const [],
      error: null,
    );
  }

  // true mientras se hace la primera carga (se muestra el spinner grande).
  final bool isInitialLoading;
  // true mientras se hace "pull to refresh".
  final bool isRefreshing;
  // Lista de noticias ya cargadas.
  final List<NewsItem> items;
  // Último error ocurrido, si hay alguno.
  final AppException? error;

  bool get hasError => error != null;
  // La lista se considera "vacía de verdad" solo si no está cargando nada.
  bool get isEmpty => !isInitialLoading && !isRefreshing && items.isEmpty;

  // Crea una copia del estado cambiando solo los campos que se indiquen.
  NewsState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    List<NewsItem>? items,
    Object? error = _unset,
  }) {
    return NewsState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      items: items ?? this.items,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [isInitialLoading, isRefreshing, items, error];
}
