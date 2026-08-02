// Angel Daniel Genao 2024-1169
// Molde de datos para "una noticia", sin importar de qué fuente vino
// (RSS de un medio dominicano o NewsData.io). No sabe nada de APIs ni
// de la pantalla, solo describe la información — así la UI y el resto
// de la app nunca necesitan saber de dónde salió cada noticia.

import 'package:equatable/equatable.dart';

class NewsItem extends Equatable {
  const NewsItem({
    required this.title,
    required this.description,
    required this.image,
    required this.url,
    required this.sourceName,
    required this.sourceUrl,
    this.publishedAt,
  });

  final String title;
  // Descripción/resumen corto del artículo.
  final String description;
  // URL de la foto destacada.
  final String image;
  // Enlace al artículo original, para abrirlo en el detalle.
  final String url;
  // Nombre del medio que publicó la noticia (ej: "Diario Libre").
  final String sourceName;
  // Enlace al sitio del medio.
  final String sourceUrl;
  // Fecha de publicación; puede no venir, por eso es opcional (nullable).
  final DateTime? publishedAt;

  @override
  List<Object?> get props => [
    title,
    description,
    image,
    url,
    sourceName,
    sourceUrl,
    publishedAt,
  ];
}
