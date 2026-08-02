// Angel Daniel Genao 2024-1169
// Provider que expone el VideosController y su VideosState a la pantalla.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'videos_controller.dart';
import 'videos_state.dart';

final videosControllerProvider =
    NotifierProvider<VideosController, VideosState>(VideosController.new);
