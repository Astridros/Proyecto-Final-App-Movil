// Angel Daniel Genao 2024-1169
// Pantalla de detalle de UN video: lo reproduce DENTRO de la app usando
// un WebView que carga el reproductor embebido de YouTube, y además deja
// un botón para abrirlo en YouTube si se prefiere.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/video.dart';

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key, required this.video});

  final Video video;

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Se carga el reproductor embebido de YouTube dentro de un WebView.
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(widget.video.embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.video.description.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del video')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reproductor de YouTube embebido dentro de la app.
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WebViewWidget(controller: _webViewController),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                widget.video.title.isEmpty
                    ? 'Video sin título'
                    : widget.video.title,
                style: AppTextStyles.headingSmall,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing12),
                Text(description, style: AppTextStyles.bodyLarge),
              ],
              const SizedBox(height: AppDimensions.spacing24),
              // Alternativa por si el usuario prefiere verlo en YouTube.
              AppButton.outlined(
                label: 'Abrir en YouTube',
                icon: Icons.open_in_new_rounded,
                width: double.infinity,
                onPressed: () {
                  launchUrl(
                    Uri.parse(widget.video.url),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
