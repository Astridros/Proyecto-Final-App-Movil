// Angel Daniel Genao 2024-1169
// Convierte un elemento del JSON del backend de Ocupa2 en un Video.
// Forma real de un elemento (verificada con una petición real a
// GET https://ocupa2.ia3x.com/apix/videos):
// { id, youtubeId, url, title, description, thumbnail, order }

import '../../domain/entities/video.dart';
import 'videos_json_parse_utils.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.youtubeId,
    required super.url,
    required super.title,
    required super.description,
    required super.thumbnail,
    required super.order,
  });

  factory VideoModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'El video');

    return VideoModel(
      id: requiredString(map, 'id', 'El video'),
      youtubeId: requiredString(map, 'youtubeId', 'El video'),
      url: optionalString(map, 'url'),
      title: optionalString(map, 'title'),
      description: optionalString(map, 'description'),
      thumbnail: optionalString(map, 'thumbnail'),
      order: intValue(map, 'order'),
    );
  }
}
