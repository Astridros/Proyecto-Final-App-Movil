import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../offers/domain/entities/offer.dart';
import '../../../offers/presentation/providers/offers_presentation_providers.dart';
import '../widgets/offer_map_bottom_card.dart';

class OffersMapScreen extends ConsumerStatefulWidget {
  const OffersMapScreen({super.key});

  @override
  ConsumerState<OffersMapScreen> createState() => _OffersMapScreenState();
}

class _OffersMapScreenState extends ConsumerState<OffersMapScreen> {
  static const LatLng _defaultCenter = LatLng(18.4861, -69.9312);

  Offer? _selectedOffer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      final state = ref.read(offersControllerProvider);

      if (state.offers.isEmpty && !state.isInitialLoading) {
        ref.read(offersControllerProvider.notifier).loadInitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersControllerProvider);
    final controller = ref.read(offersControllerProvider.notifier);

    final offersWithLocation = state.offers
        .where(_hasValidLocation)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de ofertas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar ofertas',
            onPressed: state.isRefreshing
                ? null
                : () async {
                    await controller.refresh();

                    if (!mounted) {
                      return;
                    }

                    final updatedOffers = ref
                        .read(offersControllerProvider)
                        .offers;

                    if (_selectedOffer != null &&
                        !updatedOffers.any(
                          (offer) => offer.id == _selectedOffer!.id,
                        )) {
                      setState(() {
                        _selectedOffer = null;
                      });
                    }
                  },
            icon: state.isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildContent(
          stateIsLoading: state.isInitialLoading,
          hasOffers: state.offers.isNotEmpty,
          errorMessage: state.error?.message,
          offersWithLocation: offersWithLocation,
          onRetry: controller.refresh,
        ),
      ),
    );
  }

  Widget _buildContent({
    required bool stateIsLoading,
    required bool hasOffers,
    required String? errorMessage,
    required List<Offer> offersWithLocation,
    required Future<void> Function() onRetry,
  }) {
    if (stateIsLoading && !hasOffers) {
      return const AppLoading(message: 'Cargando ofertas en el mapa...');
    }

    if (errorMessage != null && !hasOffers) {
      return AppErrorView(
        title: 'No fue posible cargar el mapa de ofertas',
        message: errorMessage,
        onRetry: () {
          onRetry();
        },
      );
    }

    if (offersWithLocation.isEmpty) {
      return const AppEmptyState(
        icon: Icons.location_off_outlined,
        title: 'No hay ofertas con ubicación',
        description:
            'Las ofertas disponibles todavía no tienen una ubicación válida '
            'para mostrarse en el mapa.',
      );
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _initialCenter(offersWithLocation),
            initialZoom: 12,
            onTap: (_, _) {
              if (_selectedOffer == null) {
                return;
              }

              setState(() {
                _selectedOffer = null;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ocupa2.app',
            ),
            MarkerLayer(
              markers: offersWithLocation
                  .map(_buildMarker)
                  .toList(growable: false),
            ),
            RichAttributionWidget(
              attributions: const [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        Positioned(
          top: AppDimensions.spacing12,
          left: AppDimensions.spacing12,
          right: AppDimensions.spacing12,
          child: _OffersCounter(count: offersWithLocation.length),
        ),

        if (_selectedOffer != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: OfferMapBottomCard(
                offer: _selectedOffer!,
                onClose: () {
                  setState(() {
                    _selectedOffer = null;
                  });
                },
                onViewOffer: () {
                  context.pushNamed(
                    RouteNames.offerDetail,
                    pathParameters: {'id': _selectedOffer!.id},
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Marker _buildMarker(Offer offer) {
    final isSelected = _selectedOffer?.id == offer.id;

    return Marker(
      point: LatLng(offer.location.lat, offer.location.lng),
      width: 56,
      height: 56,
      child: Semantics(
        button: true,
        label: 'Oferta de ${offer.jobTypeName} en ${offer.address}',
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedOffer = offer;
            });
          },
          child: Icon(
            Icons.location_on_rounded,
            size: isSelected ? 52 : 44,
            color: isSelected ? AppColors.secondary : AppColors.primary,
          ),
        ),
      ),
    );
  }

  bool _hasValidLocation(Offer offer) {
    final lat = offer.location.lat;
    final lng = offer.location.lng;

    if (!lat.isFinite || !lng.isFinite) {
      return false;
    }

    if (lat < -90 || lat > 90) {
      return false;
    }

    if (lng < -180 || lng > 180) {
      return false;
    }

    if (lat == 0 && lng == 0) {
      return false;
    }

    return true;
  }

  LatLng _initialCenter(List<Offer> offers) {
    if (offers.isEmpty) {
      return _defaultCenter;
    }

    var latitude = 0.0;
    var longitude = 0.0;

    for (final offer in offers) {
      latitude += offer.location.lat;
      longitude += offer.location.lng;
    }

    return LatLng(latitude / offers.length, longitude / offers.length);
  }
}

class _OffersCounter extends StatelessWidget {
  const _OffersCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: AppDimensions.spacing8),
              Text(
                count == 1
                    ? '1 oferta en el mapa'
                    : '$count ofertas en el mapa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
