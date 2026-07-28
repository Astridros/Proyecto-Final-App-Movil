import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/job_type.dart';
import '../../domain/entities/offer.dart';

const _unset = Object();

class OffersState extends Equatable {
  OffersState({
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.isFiltering,
    required List<JobType> jobTypes,
    required List<Offer> offers,
    required this.selectedJobTypeKey,
    required this.selectedContractType,
    required this.error,
  }) : jobTypes = List.unmodifiable(jobTypes),
       offers = List.unmodifiable(offers);

  factory OffersState.initial() {
    return OffersState(
      isInitialLoading: false,
      isRefreshing: false,
      isFiltering: false,
      jobTypes: const [],
      offers: const [],
      selectedJobTypeKey: null,
      selectedContractType: null,
      error: null,
    );
  }

  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isFiltering;
  final List<JobType> jobTypes;
  final List<Offer> offers;
  final String? selectedJobTypeKey;
  final String? selectedContractType;
  final AppException? error;

  bool get hasError => error != null;
  bool get isEmpty =>
      !isInitialLoading && !isRefreshing && !isFiltering && offers.isEmpty;
  bool get hasOffers => offers.isNotEmpty;
  bool get hasActiveFilters =>
      selectedJobTypeKey != null || selectedContractType != null;

  OffersState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isFiltering,
    List<JobType>? jobTypes,
    List<Offer>? offers,
    Object? selectedJobTypeKey = _unset,
    Object? selectedContractType = _unset,
    Object? error = _unset,
  }) {
    return OffersState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFiltering: isFiltering ?? this.isFiltering,
      jobTypes: jobTypes ?? this.jobTypes,
      offers: offers ?? this.offers,
      selectedJobTypeKey: identical(selectedJobTypeKey, _unset)
          ? this.selectedJobTypeKey
          : selectedJobTypeKey as String?,
      selectedContractType: identical(selectedContractType, _unset)
          ? this.selectedContractType
          : selectedContractType as String?,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    isRefreshing,
    isFiltering,
    jobTypes,
    offers,
    selectedJobTypeKey,
    selectedContractType,
    error,
  ];
}
