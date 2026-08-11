import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/offer.dart';
import '../providers/offers_presentation_providers.dart';

class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(myOffersControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myOffersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas')),
      body: RefreshIndicator(
        onRefresh: ref.read(myOffersControllerProvider.notifier).load,
        child: state.isLoading && state.offers.isEmpty
            ? const AppLoading(message: 'Cargando tus ofertas...')
            : state.error != null && state.offers.isEmpty
            ? AppErrorView(
                title: 'No pudimos cargar tus ofertas',
                message: state.error?.message ?? 'Ocurrió un error inesperado.',
                onRetry: ref.read(myOffersControllerProvider.notifier).load,
              )
            : state.offers.isEmpty
            ? const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'Aún no has publicado ofertas',
                      description: 'Las ofertas que publiques aparecerán aquí.',
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                itemCount: state.offers.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppDimensions.spacing16),
                itemBuilder: (context, index) {
                  final offer = state.offers[index];
                  final isInactive = _isInactive(offer.status);
                  final isSubmitting = state.deactivatingIds.contains(offer.id);

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MyOfferContent(offer: offer),
                          const SizedBox(height: AppDimensions.spacing16),
                          Wrap(
                            spacing: AppDimensions.spacing12,
                            runSpacing: AppDimensions.spacing8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Chip(
                                avatar: Icon(
                                  isInactive
                                      ? Icons.visibility_off_outlined
                                      : Icons.check_circle_outline,
                                  size: 18,
                                ),
                                label: Text(isInactive ? 'Inactiva' : 'Activa'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: isInactive || isSubmitting
                                    ? null
                                    : () => _confirmDeactivate(offer),
                                icon: isSubmitting
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.visibility_off_outlined),
                                label: Text(
                                  isSubmitting
                                      ? 'Desactivando...'
                                      : 'Desactivar',
                                ),
                                style: FilledButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  bool _isInactive(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'inactive' ||
        normalized == 'inactiva' ||
        normalized == 'deactivated' ||
        normalized == 'disabled';
  }

  Future<void> _confirmDeactivate(Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar oferta'),
        content: const Text(
          'La oferta dejará de aparecer públicamente y no recibirá nuevas postulaciones. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(myOffersControllerProvider.notifier)
        .deactivate(offer.id);
    if (!mounted) return;

    final state = ref.read(myOffersControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Oferta desactivada correctamente.'
              : state.error?.message ?? 'No fue posible desactivar la oferta.',
        ),
      ),
    );
  }
}

class _MyOfferContent extends StatelessWidget {
  const _MyOfferContent({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final title = offer.jobTypeName.trim().isNotEmpty
        ? offer.jobTypeName.trim()
        : offer.jobTypeKey.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.work_outline, color: AppColors.primary),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          title.isEmpty ? 'Oferta de trabajo' : title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (offer.description.trim().isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            offer.description.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (offer.address.trim().isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'Ubicación: ${offer.address.trim()}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppDimensions.spacing8),
        Text('Postulantes: ${offer.applicantsCount}'),
      ],
    );
  }
}
