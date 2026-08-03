import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../applications/domain/entities/application.dart';
import '../../domain/entities/apply_offer_result.dart';
import '../../domain/entities/offer.dart';

const _unset = Object();

class OfferDetailState extends Equatable {
  const OfferDetailState({
    required this.isInitialLoading,
    required this.isSubmitting,
    required this.offer,
    required this.applicationResult,
    required this.hasAlreadyApplied,
    required this.existingApplication,
    required this.error,
    required this.successMessage,
  });

  factory OfferDetailState.initial() {
    return const OfferDetailState(
      isInitialLoading: false,
      isSubmitting: false,
      offer: null,
      applicationResult: null,
      hasAlreadyApplied: false,
      existingApplication: null,
      error: null,
      successMessage: null,
    );
  }

  final bool isInitialLoading;
  final bool isSubmitting;
  final Offer? offer;
  final ApplyOfferResult? applicationResult;
  final bool hasAlreadyApplied;
  final Application? existingApplication;
  final AppException? error;
  final String? successMessage;

  bool get hasOffer => offer != null;
  bool get hasAppliedSuccessfully =>
      applicationResult != null || hasAlreadyApplied;

  OfferDetailState copyWith({
    bool? isInitialLoading,
    bool? isSubmitting,
    Object? offer = _unset,
    Object? applicationResult = _unset,
    bool? hasAlreadyApplied,
    Object? existingApplication = _unset,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return OfferDetailState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      offer: identical(offer, _unset) ? this.offer : offer as Offer?,
      applicationResult: identical(applicationResult, _unset)
          ? this.applicationResult
          : applicationResult as ApplyOfferResult?,
      hasAlreadyApplied: hasAlreadyApplied ?? this.hasAlreadyApplied,
      existingApplication: identical(existingApplication, _unset)
          ? this.existingApplication
          : existingApplication as Application?,
      error: identical(error, _unset) ? this.error : error as AppException?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    isSubmitting,
    offer,
    applicationResult,
    hasAlreadyApplied,
    existingApplication,
    error,
    successMessage,
  ];
}
