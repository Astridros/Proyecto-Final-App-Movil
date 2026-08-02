// Angel Daniel Genao 2024-1169
// Widget visual: tarjeta de UN video con su miniatura (con ícono de play
// encima), título y descripción corta. Se usa en la lista de VideosScreen.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video, this.onTap});

  final Video video;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final description = video.description.trim();

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Miniatura del video con el ícono de "play" encima.
          _VideoThumbnail(thumbnailUrl: video.thumbnail),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title.isEmpty ? 'Video sin título' : video.title,
                  style: AppTextStyles.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Muestra la miniatura del video (16:9) con un ícono grande de "play"
// centrado encima, para que se note que es un video y no una foto normal.
class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.thumbnailUrl});

  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final validUrl = _validImageUrl(thumbnailUrl);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLarge),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            validUrl == null
                ? const _ThumbnailPlaceholder()
                : CachedNetworkImage(
                    imageUrl: validUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (context, url) =>
                        const _ThumbnailPlaceholder(),
                    errorWidget: (context, url, error) =>
                        const _ThumbnailPlaceholder(),
                  ),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Comprueba que el texto sea una URL real antes de intentar mostrarla.
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

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surfaceSoft),
      child: Center(
        child: Icon(
          Icons.smart_display_outlined,
          color: AppColors.primary,
          size: AppDimensions.iconLarge,
        ),
      ),
    );
  }
}
