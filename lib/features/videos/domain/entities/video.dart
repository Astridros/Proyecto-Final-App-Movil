// Angel Daniel Genao 2024-1169
// Molde de datos para "un video" tal como lo entrega el backend propio
// de Ocupa2 (GET /videos, https://ocupa2.ia3x.com/apix): videos de
// YouTube curados a mano por el equipo sobre cómo buscar/conseguir
// empleo. No sabe nada de la API ni de la pantalla.

import 'package:equatable/equatable.dart';

class Video extends Equatable {
  const Video({
    required this.id,
    required this.youtubeId,
    required this.url,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.order,
  });

  final String id;
  // Código del video en YouTube (lo que va después de "v=" en la URL).
  final String youtubeId;
  // Enlace completo de YouTube, para abrirlo fuera de la app.
  final String url;
  final String title;
  final String description;
  final String thumbnail;
  // Orden en que el equipo de Ocupa2 quiere que aparezca en la lista.
  final int order;

  // URL del reproductor embebido de YouTube, para verlo dentro de la app.
  String get embedUrl => 'https://www.youtube.com/embed/$youtubeId';

  @override
  List<Object?> get props => [
    id,
    youtubeId,
    url,
    title,
    description,
    thumbnail,
    order,
  ];
}
