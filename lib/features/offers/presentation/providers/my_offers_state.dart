import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/offer.dart';

const _unset = Object();

class MyOffersState extends Equatable {
  MyOffersState({
    required this.isInitialLoading,
    required this.isRefreshing,
    required List<Offer> offers,
    required this.error,
  }) : offers = List.unmodifiable(offers);

  factory MyOffersState.initial() {
    return MyOffersState(
      isInitialLoading: false,
      isRefreshing: false,
      offers: const [],
      error: null,
    );
  }

  final bool isInitialLoading;
  final bool isRefreshing;
  final List<Offer> offers;
  final AppException? error;

  bool get hasError => error != null;

  bool get isEmpty =>
      !isInitialLoading &&
          !isRefreshing &&
          offers.isEmpty;

  bool get hasOffers => offers.isNotEmpty;

  MyOffersState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    List<Offer>? offers,
    Object? error = _unset,
  }) {
    return MyOffersState(
      isInitialLoading:
      isInitialLoading ??
          this.isInitialLoading,
      isRefreshing:
      isRefreshing ??
          this.isRefreshing,
      offers: offers ?? this.offers,
      error: identical(error, _unset)
          ? this.error
          : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    isRefreshing,
    offers,
    error,
  ];
}
