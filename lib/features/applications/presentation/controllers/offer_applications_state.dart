import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/application.dart';

const _unset = Object();

class OfferApplicationsState
    extends Equatable {
  OfferApplicationsState({
    required this.isLoading,
    required this.isRefreshing,
    required this.isUpdating,
    required List<Application> applications,
    required this.error,
    this.updatingApplicationId,
  }) : applications =
  List.unmodifiable(applications);

  factory OfferApplicationsState.initial() {
    return OfferApplicationsState(
      isLoading: false,
      isRefreshing: false,
      isUpdating: false,
      applications: const [],
      error: null,
      updatingApplicationId: null,
    );
  }

  final bool isLoading;

  final bool isRefreshing;

  final bool isUpdating;

  final List<Application> applications;

  final AppException? error;

  final String? updatingApplicationId;

  OfferApplicationsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isUpdating,
    List<Application>? applications,
    Object? error = _unset,
    Object? updatingApplicationId = _unset,
  }) {
    return OfferApplicationsState(
      isLoading:
      isLoading ?? this.isLoading,
      isRefreshing:
      isRefreshing ?? this.isRefreshing,
      isUpdating:
      isUpdating ?? this.isUpdating,
      applications:
      applications ?? this.applications,
      error: identical(error, _unset)
          ? this.error
          : error as AppException?,
      updatingApplicationId:
      identical(
        updatingApplicationId,
        _unset,
      )
          ? this.updatingApplicationId
          : updatingApplicationId
      as String?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    isUpdating,
    applications,
    error,
    updatingApplicationId,
  ];
}