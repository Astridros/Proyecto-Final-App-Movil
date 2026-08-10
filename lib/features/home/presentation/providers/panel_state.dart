import 'package:equatable/equatable.dart';

import '../../../offers/domain/entities/offer.dart';

// Yeison Familia - modulo Inicio.
class PanelState extends Equatable {
  const PanelState({
    required this.isLoadingOffers,
    required this.offers,
    required this.offersError,
  });

  factory PanelState.initial() {
    return const PanelState(
      isLoadingOffers: false,
      offers: [],
      offersError: false,
    );
  }

  final bool isLoadingOffers;
  final List<Offer> offers;
  final bool offersError;

  PanelState copyWith({
    bool? isLoadingOffers,
    List<Offer>? offers,
    bool? offersError,
  }) {
    return PanelState(
      isLoadingOffers: isLoadingOffers ?? this.isLoadingOffers,
      offers: offers ?? this.offers,
      offersError: offersError ?? this.offersError,
    );
  }

  @override
  List<Object?> get props => [isLoadingOffers, offers, offersError];
}
