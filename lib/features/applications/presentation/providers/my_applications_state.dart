import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/application.dart';

const _unset = Object();

class MyApplicationsState extends Equatable {
  MyApplicationsState({
    required this.isLoading,
    required this.isRefreshing,
    required List<Application> applications,
    required this.error,
  }) : applications = List.unmodifiable(applications);

  factory MyApplicationsState.initial() {
    return MyApplicationsState(
      isLoading: false,
      isRefreshing: false,
      applications: const [],
      error: null,
    );
  }

  final bool isLoading;
  final bool isRefreshing;

  final List<Application> applications;

  final AppException? error;

  MyApplicationsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<Application>? applications,
    Object? error = _unset,
  }) {
    return MyApplicationsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      applications: applications ?? this.applications,
      error: identical(error, _unset)
          ? this.error
          : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    applications,
    error,
  ];
}