// Angel Daniel Genao 2024-1169
// Pantalla de detalle de UN video: lo reproduce DENTRO de la app usando
// un WebView que carga el reproductor embebido de YouTube, y además deja
// un botón para abrirlo en YouTube si se prefiere.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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

  // Origen que se declara ante YouTube. Debe ser un dominio real y distinto
  // de youtube.com: si el documento dice ser youtube.com sin serlo, el player
  // corta con "error 152". Se usa el dominio propio de Ocupa2.
  static const String _playerOrigin = 'https://ocupa2.ia3x.com';

  // El WebView de Android manda por defecto un User-Agent con el token "; wv",
  // que YouTube trata como cliente no permitido y también termina en error 152.
  // Se declara el UA de un Chrome normal de Android.
  static const String _chromeUserAgent =
      'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    // El reproductor NO se carga con loadRequest(embedUrl): al abrir
    // /embed/<id> como página principal, YouTube no recibe un origen válido
    // y responde "Video no disponible". Se carga un HTML propio con el
    // iframe, sirviéndolo bajo el origen de Ocupa2.
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(_chromeUserAgent)
      ..loadHtmlString(
        _playerHtml(widget.video.youtubeId),
        baseUrl: _playerOrigin,
      );

    // En Android el WebView exige un gesto del usuario sobre el propio
    // <video> antes de reproducir; el botón de play de YouTube es JS, así
    // que sin esto el video nunca arranca.
    final platform = _webViewController.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  // playsinline=1 evita que Android intente pantalla completa nativa (que
  // requiere un handler propio y termina en pantalla negra). rel=0 quita
  // los videos sugeridos de otros canales al terminar. origin debe coincidir
  // con el baseUrl bajo el que se sirve este HTML.
  String _playerHtml(String youtubeId) =>
      '<!DOCTYPE html>'
      '<html><head>'
      '<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">'
      '</head>'
      '<body style="margin:0;padding:0;background:#000">'
      '<iframe style="border:0;width:100%;height:100%;position:absolute;top:0;left:0"'
      ' src="https://www.youtube-nocookie.com/embed/$youtubeId'
      '?playsinline=1&rel=0&origin=$_playerOrigin"'
      ' allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"'
      ' allowfullscreen></iframe>'
      '</body></html>';

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
