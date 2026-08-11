import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/offer.dart';

const _unset = Object();

class MyOffersState extends Equatable {
  MyOffersState({
    required this.isLoading,
    required List<Offer> offers,
    required Set<String> deactivatingIds,
    required this.error,
  }) : offers = List.unmodifiable(offers),
       deactivatingIds = Set.unmodifiable(deactivatingIds);

  factory MyOffersState.initial() => MyOffersState(
    isLoading: false,
    offers: const [],
    deactivatingIds: const {},
    error: null,
  );

  final bool isLoading;
  final List<Offer> offers;
  final Set<String> deactivatingIds;
  final AppException? error;

  MyOffersState copyWith({
    bool? isLoading,
    List<Offer>? offers,
    Set<String>? deactivatingIds,
    Object? error = _unset,
  }) {
    return MyOffersState(
      isLoading: isLoading ?? this.isLoading,
      offers: offers ?? this.offers,
      deactivatingIds: deactivatingIds ?? this.deactivatingIds,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [isLoading, offers, deactivatingIds, error];
}
