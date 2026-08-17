import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/application.dart';

class MyApplicationsState {
  const MyApplicationsState({
    required this.applications,
    required this.isLoading,
    required this.isRefreshing,
    required this.error,
  });

  final List<Application> applications;
  final bool isLoading;
  final bool isRefreshing;
  final AppException? error;

  factory MyApplicationsState.initial() {
    return const MyApplicationsState(
      applications: [],
      isLoading: false,
      isRefreshing: false,
      error: null,
    );
  }

  MyApplicationsState copyWith({
    List<Application>? applications,
    bool? isLoading,
    bool? isRefreshing,
    AppException? error,
  }) {
    return MyApplicationsState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}