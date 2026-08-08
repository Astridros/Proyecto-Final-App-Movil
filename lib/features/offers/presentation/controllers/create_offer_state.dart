import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/offer.dart';

const _unset = Object();

class CreateOfferState extends Equatable {
  const CreateOfferState({
    required this.isSubmitting,
    required this.createdOffer,
    required this.error,
  });

  factory CreateOfferState.initial() {
    return const CreateOfferState(
      isSubmitting: false,
      createdOffer: null,
      error: null,
    );
  }

  final bool isSubmitting;
  final Offer? createdOffer;
  final AppException? error;

  bool get hasError => error != null;
  bool get isSuccess => createdOffer != null;

  CreateOfferState copyWith({
    bool? isSubmitting,
    Object? createdOffer = _unset,
    Object? error = _unset,
  }) {
    return CreateOfferState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdOffer: identical(createdOffer, _unset)
          ? this.createdOffer
          : createdOffer as Offer?,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, createdOffer, error];
}
