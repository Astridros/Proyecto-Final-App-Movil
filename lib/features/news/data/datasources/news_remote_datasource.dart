// Angel Daniel Genao 2024-1169
// Único lugar que sabe llamar al endpoint GET /news del backend propio
// de Ocupa2. No requiere llave propia y reutiliza el ApiClient compartido
// de toda la app (el mismo que usan Ofertas, Perfil y Videos) — nunca se
// crea una instancia nueva de Dio. No filtra ni transforma el contenido:
// se muestra tal cual lo entrega la API.

import '../../../../core/network/api_client.dart';
import '../../domain/entities/news_item.dart';
import '../models/news_item_model.dart';
import '../models/news_json_parse_utils.dart';

abstract interface class NewsRemoteDataSource {
  Future<List<NewsItem>> getNews();
}

class OcupaBackendNewsRemoteDataSource implements NewsRemoteDataSource {
  const OcupaBackendNewsRemoteDataSource(this._apiClient);

  static const _newsPath = '/news';

  final ApiClient _apiClient;

  @override
  Future<List<NewsItem>> getNews() async {
    final response = await _apiClient.get<Object?>(_newsPath);

    final map = requireJsonMap(response.data, 'La respuesta');
    if (map['ok'] != true) {
      return const [];
    }

    final data = map['data'];
    if (data is! List) {
      return const [];
    }

    return List.unmodifiable(data.whereType<Map>().map(NewsItemModel.fromJson));
  }
}
