// Angel Daniel Genao 2024-1169
// Pantalla principal del módulo de noticias: pide la lista al abrirse,
// y según el NewsState muestra loading, error, lista vacía o la lista real.
// Al tocar una noticia navega a NewsDetailScreen pasando esa noticia completa.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton_list.dart';
import '../providers/news_presentation_providers.dart';
import '../providers/news_state.dart';
import '../widgets/news_card.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  @override
  void initState() {
    super.initState();
    // Se pide la carga inicial apenas se abre la pantalla.
    // Se usa Future.microtask para evitar modificar providers mientras
    // Flutter todavía está construyendo el widget (evita errores).
    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref.read(newsControllerProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    // "state" es lo que hay que mostrar; "controller" son las acciones (refresh).
    final state = ref.watch(newsControllerProvider);
    final controller = ref.read(newsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Noticias de empleo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing16,
          ),
          child: state.isInitialLoading
              // Mientras carga la primera vez: tarjetas "esqueleto".
              ? const AppSkeletonList()
              // RefreshIndicator permite "deslizar hacia abajo" para recargar.
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: _NewsContent(
                    state: state,
                    onRetry: controller.retry,
                  ),
                ),
        ),
      ),
    );
  }
}

// Decide qué dibujar según el estado: error sin datos, lista vacía o la lista.
class _NewsContent extends StatelessWidget {
  const _NewsContent({required this.state, required this.onRetry});

  final NewsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Caso 1: hubo un error y no hay noticias para mostrar.
    if (state.error != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AppErrorView(
            title: 'No fue posible cargar las noticias',
            message: state.error!.message,
            onRetry: onRetry,
          ),
        ],
      );
    }

    // Caso 2: no hay error, pero la lista está vacía.
    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const AppEmptyState(
            icon: Icons.newspaper_outlined,
            title: 'No hay noticias disponibles',
            description: 'Vuelve a intentarlo más tarde.',
          ),
        ],
      );
    }

    // Caso 3: hay noticias, se dibuja la lista con una NewsCard por cada una.
    return ListView.builder(
      key: const PageStorageKey<String>('news-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final newsItem = state.items[index];
        return NewsCard(
          newsItem: newsItem,
          onTap: () {
            // Al tocar la tarjeta, se navega al detalle y se le manda
            // la noticia completa (no hace falta volver a pedirla a la API,
            // porque el endpoint /news no tiene una ruta de detalle por id).
            context.pushNamed(RouteNames.newsDetail, extra: newsItem);
          },
        );
      },
    );
  }
}
