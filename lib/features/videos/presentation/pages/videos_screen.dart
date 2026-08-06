// Angel Daniel Genao 2024-1169
// Pantalla principal del módulo de videos: pide la lista al abrirse y,
// según VideosState, muestra loading, error, lista vacía o la lista real.
// Al tocar un video navega a VideoDetailScreen con ese video completo.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton_list.dart';
import '../providers/videos_presentation_providers.dart';
import '../providers/videos_state.dart';
import '../widgets/video_card.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  @override
  void initState() {
    super.initState();
    // Se pide la carga inicial apenas se abre la pantalla, en un microtask
    // para no modificar providers mientras el widget se está construyendo.
    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref.read(videosControllerProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videosControllerProvider);
    final controller = ref.read(videosControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Videos educativos y tutoriales')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing16,
          ),
          child: state.isInitialLoading
              ? const AppSkeletonList()
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: _VideosContent(
                    state: state,
                    onRetry: controller.retry,
                  ),
                ),
        ),
      ),
    );
  }
}

// Decide qué mostrar según el estado actual: error, vacío o lista con datos.
class _VideosContent extends StatelessWidget {
  const _VideosContent({required this.state, required this.onRetry});

  final VideosState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Caso 1: hubo error y no hay videos guardados para mostrar.
    if (state.error != null && state.videos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AppErrorView(
            title: 'No fue posible cargar los videos',
            message: state.error!.message,
            onRetry: onRetry,
          ),
        ],
      );
    }

    // Caso 2: no hay error, pero tampoco hay videos.
    if (state.videos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const AppEmptyState(
            icon: Icons.smart_display_outlined,
            title: 'No hay videos disponibles',
            description: 'Vuelve a intentarlo más tarde.',
          ),
        ],
      );
    }

    // Caso 3: hay videos, se dibuja la lista con una VideoCard por cada uno.
    return ListView.builder(
      key: const PageStorageKey<String>('videos-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.videos.length,
      itemBuilder: (context, index) {
        final video = state.videos[index];
        return VideoCard(
          video: video,
          onTap: () {
            context.pushNamed(RouteNames.videoDetail, extra: video);
          },
        );
      },
    );
  }
}
