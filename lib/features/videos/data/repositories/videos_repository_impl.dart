// Angel Daniel Genao 2024-1169
// Puente entre el contrato VideosRepository y el datasource real
// (backend de Ocupa2). Cachea la lista completa en memoria durante
// 10 minutos para no repetir la llamada cada vez que el usuario vuelve
// a la pantalla de videos.

import '../../../../core/cache/ttl_cache.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_remote_datasource.dart';

class VideosRepositoryImpl implements VideosRepository {
  VideosRepositoryImpl(this._remoteDataSource, {TtlCache<List<Video>>? cache})
    : _cache = cache ?? TtlCache<List<Video>>();

  final VideosRemoteDataSource _remoteDataSource;
  final TtlCache<List<Video>> _cache;

  @override
  Future<List<Video>> getVideos({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.value;
      if (cached != null) {
        return cached;
      }
    }

    final videos = await _remoteDataSource.getVideos();
    _cache.set(videos);
    return videos;
  }
}
