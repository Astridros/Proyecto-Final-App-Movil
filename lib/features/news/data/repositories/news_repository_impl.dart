// Angel Daniel Genao 2024-1169
// Puente entre el contrato NewsRepository y el datasource real (backend
// de Ocupa2). Cachea la lista completa en memoria durante 10 minutos
// para no repetir la llamada cada vez que el usuario vuelve a la
// pantalla de noticias.

import '../../../../core/cache/ttl_cache.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._remoteDataSource, {TtlCache<List<NewsItem>>? cache})
    : _cache = cache ?? TtlCache<List<NewsItem>>();

  final NewsRemoteDataSource _remoteDataSource;
  final TtlCache<List<NewsItem>> _cache;

  @override
  Future<List<NewsItem>> getNews({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.value;
      if (cached != null) {
        return cached;
      }
    }

    final news = await _remoteDataSource.getNews();
    _cache.set(news);
    return news;
  }
}
