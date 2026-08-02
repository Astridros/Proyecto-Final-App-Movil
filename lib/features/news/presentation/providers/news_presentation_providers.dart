// Angel Daniel Genao 2024-1169
// Provider que expone el NewsController y su NewsState a la pantalla.
// La pantalla hace ref.watch(newsControllerProvider) para escuchar cambios.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'news_controller.dart';
import 'news_state.dart';

final newsControllerProvider = NotifierProvider<NewsController, NewsState>(
  NewsController.new,
);
