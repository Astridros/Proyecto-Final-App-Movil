// Angel Daniel Genao 2024-1169
// Pantalla de detalle de UNA noticia. No vuelve a llamar la API: recibe la
// noticia completa desde NewsScreen y solo la muestra más grande, con un
// botón para abrir el artículo original en el navegador del celular.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/news_item.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.newsItem});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    final validImageUrl = _validUrl(newsItem.image);
    final validArticleUrl = _validUrl(newsItem.url);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la noticia')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen grande de la noticia (si la URL es válida).
              if (validImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      validImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: AppDimensions.spacing16),
              // Título completo (sin recortar, a diferencia de la tarjeta).
              Text(newsItem.title, style: AppTextStyles.headingSmall),
              const SizedBox(height: AppDimensions.spacing8),
              // Fuente + fecha.
              Text(
                _sourceLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              // Descripción completa de la noticia.
              Text(
                newsItem.description.trim().isEmpty
                    ? 'Esta noticia no tiene una descripción disponible.'
                    : newsItem.description,
                style: AppTextStyles.bodyLarge,
              ),
              // Botón para abrir el artículo original fuera de la app.
              if (validArticleUrl != null) ...[
                const SizedBox(height: AppDimensions.spacing24),
                AppButton(
                  label: 'Leer artículo completo',
                  icon: Icons.open_in_new_rounded,
                  width: double.infinity,
                  onPressed: () {
                    launchUrl(
                      Uri.parse(validArticleUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Arma el texto "fuente · fecha" para mostrarlo debajo del título.
  String get _sourceLabel {
    final source = newsItem.sourceName.trim();
    final date = newsItem.publishedAt;
    final parts = <String>[
      if (source.isNotEmpty) source,
      if (date != null) DateFormat('dd/MM/yyyy').format(date),
    ];

    return parts.isEmpty ? 'Fuente desconocida' : parts.join(' · ');
  }

  // Comprueba que el texto sea una URL real antes de usarla.
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
