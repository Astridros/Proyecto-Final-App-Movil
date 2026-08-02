// Angel Daniel Genao 2024-1169
// Contrato del módulo de noticias: solo dice qué se puede pedir (la lista
// completa de noticias), sin decir cómo se consigue. "forceRefresh"
// permite saltarse la caché (pull to refresh / reintentar).

import '../entities/news_item.dart';

abstract interface class NewsRepository {
  Future<List<NewsItem>> getNews({bool forceRefresh = false});
}
