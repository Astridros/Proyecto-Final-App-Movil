import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/my_offers_providers.dart';
import '../providers/my_offers_state.dart';
import '../widgets/my_offer_card.dart';

class MyOffersScreen
    extends ConsumerStatefulWidget {
  const MyOffersScreen({
    super.key,
  });

  @override
  ConsumerState<MyOffersScreen>
  createState() =>
      _MyOffersScreenState();
}

class _MyOffersScreenState
    extends ConsumerState<
        MyOffersScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(
        myOffersControllerProvider
            .notifier,
      )
          .loadInitial();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      myOffersControllerProvider,
    );

    final controller =
    ref.read(
      myOffersControllerProvider
          .notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis ofertas publicadas',
        ),
      ),
      body: SafeArea(
        child:
        state.isInitialLoading &&
            state.offers.isEmpty
            ? const AppLoading(
          message:
          'Cargando tus ofertas...',
        )
            : RefreshIndicator(
          onRefresh:
          controller.refresh,
          child:
          _MyOffersContent(
            state: state,
          ),
        ),
      ),
    );
  }
}

class _MyOffersContent
    extends StatelessWidget {
  const _MyOffersContent({
    required this.state,
  });

  final MyOffersState state;

  @override
  Widget build(
      BuildContext context,
      ) {
    if (state.error != null &&
        state.offers.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          AppErrorView(
            title:
            'No fue posible cargar tus ofertas',
            message:
            state.error!.message,
          ),
        ],
      );
    }

    if (state.offers.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.symmetric(
          horizontal:
          AppDimensions
              .screenHorizontalPadding,
        ),
        children: const [
          AppEmptyState(
            icon:
            Icons.post_add_outlined,
            title:
            'No tienes ofertas publicadas',
            description:
            'Cuando publiques una oferta aparecerá aquí.',
          ),
        ],
      );
    }

    return ListView.separated(
      key:
      const PageStorageKey<String>(
        'my-offers-list',
      ),
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.symmetric(
        horizontal:
        AppDimensions
            .screenHorizontalPadding,
        vertical:
        AppDimensions.spacing16,
      ),
      itemCount:
      state.offers.length,
      separatorBuilder: (
          _,
          _,
          ) =>
      const SizedBox(
        height:
        AppDimensions.spacing16,
      ),
      itemBuilder: (
          context,
          index,
          ) {
        final offer =
        state.offers[index];

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            MyOfferCard(
              offer: offer,
              onTap: () {
                context.pushNamed(
                  RouteNames
                      .offerDetail,
                  pathParameters: {
                    'id':
                    offer.id,
                  },
                );
              },
            ),

            const SizedBox(
              height:
              AppDimensions
                  .spacing8,
            ),

            OutlinedButton.icon(
              onPressed: () {
                context.pushNamed(
                  RouteNames
                      .offerApplications,
                  pathParameters: {
                    'id':
                    offer.id,
                  },
                );
              },
              icon: const Icon(
                Icons.people_outline,
              ),
              label: Text(
                offer.applicantsCount == 1
                    ? 'Ver 1 postulante'
                    : 'Ver ${offer.applicantsCount} postulantes',
              ),
            ),
          ],
        );
      },
    );
  }
}