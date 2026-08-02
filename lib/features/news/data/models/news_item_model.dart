// Angel Daniel Genao 2024-1169
// Convierte un artículo del JSON del backend propio de Ocupa2
// (GET /news, https://ocupa2.ia3x.com/apix) en un NewsItem.
// Forma real de un artículo (verificada con una petición real):
// { title, image, summary, date ("2026-08-02T12:07:39-04:00"), url, source }

import '../../domain/entities/news_item.dart';
import 'news_json_parse_utils.dart';

class NewsItemModel extends NewsItem {
  const NewsItemModel({
    required super.title,
    required super.description,
    required super.image,
    required super.url,
    required super.sourceName,
    required super.sourceUrl,
    super.publishedAt,
  });

  factory NewsItemModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'La noticia');
    final url = optionalString(map, 'url');

    return NewsItemModel(
      title: requiredString(map, 'title', 'La noticia'),
      description: optionalString(map, 'summary'),
      image: optionalString(map, 'image'),
      url: url,
      sourceName: optionalString(map, 'source'),
      sourceUrl: _originOf(url),
      publishedAt: optionalDate(map, 'date'),
    );
  }

  // El backend no manda la url del medio por separado, así que se arma
  // con el dominio del enlace del artículo (ej: "https://remolacha.net").
  static String _originOf(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return '';
    }

    return uri.origin;
  }
}
