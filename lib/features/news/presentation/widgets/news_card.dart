// Angel Daniel Genao 2024-1169
// Widget visual: dibuja una "tarjeta" con la imagen, título, fuente/fecha,
// descripción y un botón "Leer noticia" de UNA noticia. Se usa dentro de
// la lista de NewsScreen. Tocar la tarjeta abre el detalle; tocar el botón
// abre el artículo original directamente en el navegador.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/news_item.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.newsItem, this.onTap});

  final NewsItem newsItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final description = _cleanText(newsItem.description);
    final articleUrl = _validUrl(newsItem.url);

    // AppCard es el componente de tarjeta compartido de toda la app (borde,
    // sombra, radio). Aquí solo se arma el contenido de adentro.
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto destacada de la noticia (o un ícono si no hay imagen válida).
          _NewsImage(imageUrl: newsItem.image),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título (máximo 2 líneas, con "..." si es muy largo).
                Text(
                  newsItem.title,
                  style: AppTextStyles.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacing8),
                // Fuente de la noticia + fecha, en una sola línea.
                _SourceRow(
                  source: newsItem.sourceName,
                  date: newsItem.publishedAt,
                ),
                if (description != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  // Descripción corta (máximo 2 líneas).
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (articleUrl != null) ...[
                  const SizedBox(height: AppDimensions.spacing16),
                  AppButton.outlined(
                    label: 'Leer noticia',
                    icon: Icons.open_in_new_rounded,
                    width: double.infinity,
                    onPressed: () {
                      launchUrl(
                        Uri.parse(articleUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Convierte texto vacío en null, para no mostrar espacios de más.
  String? _cleanText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _validUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

// Fila pequeña que junta "fuente · fecha" (ej: "Diario Libre · 01/07/2026").
class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source, required this.date});

  final String source;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (source.trim().isNotEmpty) source.trim(),
      if (date != null) DateFormat('dd/MM/yyyy').format(date!),
    ];

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Icon(
          Icons.newspaper_outlined,
          size: AppDimensions.iconSmall,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: Text(
            parts.join(' · '),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Muestra la imagen de la noticia (con caché) y un ícono de reemplazo si
// la URL no es válida o la imagen falla al cargar.
class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final validUrl = _validImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLarge),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: validUrl == null
            ? const _ImagePlaceholder()
            : CachedNetworkImage(
                imageUrl: validUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => const _ImagePlaceholder(),
                errorWidget: (context, url, error) =>
                    const _ImagePlaceholder(),
              ),
      ),
    );
  }

  // Comprueba que el texto sea una URL real (con esquema http/https y host).
  String? _validImageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surfaceSoft),
      child: Center(
        child: Icon(
          Icons.newspaper_outlined,
          color: AppColors.primary,
          size: AppDimensions.iconLarge,
        ),
      ),
    );
  }
}
