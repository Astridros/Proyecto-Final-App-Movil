// Angel Daniel Genao 2024-1169
// Único lugar que sabe llamar al endpoint GET /videos del backend propio
// de Ocupa2. No requiere llave propia y reutiliza el ApiClient compartido
// de toda la app (el mismo que usan Ofertas, Perfil y la fuente de
// noticias del backend) — nunca se crea una instancia nueva de Dio.

import '../../../../core/network/api_client.dart';
import '../../domain/entities/video.dart';
import '../models/video_model.dart';
import '../models/videos_json_parse_utils.dart';

abstract interface class VideosRemoteDataSource {
  Future<List<Video>> getVideos();
}

class OcupaBackendVideosRemoteDataSource implements VideosRemoteDataSource {
  const OcupaBackendVideosRemoteDataSource(this._apiClient);

  static const _videosPath = '/videos';

  final ApiClient _apiClient;

  @override
  Future<List<Video>> getVideos() async {
    final response = await _apiClient.get<Object?>(_videosPath);

    final map = requireJsonMap(response.data, 'La respuesta');
    if (map['ok'] != true) {
      return const [];
    }

    final data = map['data'];
    if (data is! List) {
      return const [];
    }

    final videos = data.whereType<Map>().map(VideoModel.fromJson).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return List.unmodifiable(videos);
  }
}
