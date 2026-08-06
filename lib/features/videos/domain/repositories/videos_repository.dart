// Angel Daniel Genao 2024-1169
// Contrato del módulo de videos: solo dice qué se puede pedir (la lista
// completa de videos), sin decir cómo se consigue. "forceRefresh" permite
// saltarse la caché (pull to refresh / reintentar).

import '../entities/video.dart';

abstract interface class VideosRepository {
  Future<List<Video>> getVideos({bool forceRefresh = false});
}
