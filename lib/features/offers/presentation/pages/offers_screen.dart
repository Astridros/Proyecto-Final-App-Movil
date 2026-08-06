import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/offer.dart';
import '../providers/offers_presentation_providers.dart';
import '../providers/offers_state.dart';
import '../providers/offer_like_providers.dart';
import '../widgets/offer_card.dart';
import '../widgets/offers_filter_bar.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  @override
  void initState() {
    super.initState();
    // Se difiere para evitar mutar providers durante la construccion inicial.
    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref.read(offersControllerProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersControllerProvider);
    final controller = ref.read(offersControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar ofertas')),
      body: SafeArea(
        child: state.isInitialLoading
            ? const AppLoading(message: 'Cargando ofertas...')
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenHorizontalPadding,
                  vertical: AppDimensions.spacing16,
                ),
                child: Column(
                  children: [
                    OffersFilterBar(
                      jobTypes: state.jobTypes,
                      selectedJobTypeKey: state.selectedJobTypeKey,
                      selectedContractType: state.selectedContractType,
                      isFiltering: state.isFiltering,
                      enabled: !state.isInitialLoading,
                      onJobTypeChanged: controller.changeJobType,
                      onContractTypeChanged: controller.changeContractType,
                      onClearFilters: controller.clearFilters,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: _OffersContent(state: state),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _OffersContent extends StatelessWidget {
  const _OffersContent({required this.state});

  final OffersState state;

  @override
  Widget build(BuildContext context) {
    if (state.error != null && state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AppErrorView(
            title: 'No fue posible cargar las ofertas',
            message: state.error!.message,
          ),
        ],
      );
    }

    if (state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const AppEmptyState(
            icon: Icons.work_off_outlined,
            title: 'No hay ofertas disponibles',
            description: 'Prueba ajustando los filtros o recargando la lista.',
          ),
        ],
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('offers-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.offers.length,
      itemBuilder: (context, index) {
        final offer = state.offers[index];
        return _LikeAwareOfferCard(
          offer: offer,
          onTap: () {
            context.pushNamed(
              RouteNames.offerDetail,
              pathParameters: {'id': offer.id},
            );
          },
        );
      },
    );
  }
}

class _LikeAwareOfferCard extends ConsumerStatefulWidget {
  const _LikeAwareOfferCard({required this.offer, required this.onTap});

  final Offer offer;
  final VoidCallback onTap;

  @override
  ConsumerState<_LikeAwareOfferCard> createState() =>
      _LikeAwareOfferCardState();
}

class _LikeAwareOfferCardState extends ConsumerState<_LikeAwareOfferCard> {
  @override
  void initState() {
    super.initState();
    _syncFromOffer();
  }

  @override
  void didUpdateWidget(covariant _LikeAwareOfferCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.id != widget.offer.id ||
        oldWidget.offer.likedByMe != widget.offer.likedByMe ||
        oldWidget.offer.likesCount != widget.offer.likesCount) {
      _syncFromOffer();
    }
  }

  void _syncFromOffer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(offerLikeControllerProvider(widget.offer.id).notifier)
          .syncFromOffer(
            likedByMe: widget.offer.likedByMe,
            likesCount: widget.offer.likesCount,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = offerLikeControllerProvider(widget.offer.id);
    final likeState = ref.watch(provider);

    ref.listen(provider, (previous, next) {
      final error = next.error;
      if (error == null || previous?.error == error) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    });

    return OfferCard(
      offer: widget.offer,
      liked: likeState.liked,
      likesCount: likeState.likesCount,
      isLikeSubmitting: likeState.isSubmitting,
      onLikePressed: () {
        ref.read(provider.notifier).toggleLike();
      },
      onTap: widget.onTap,
    );
  }
}
