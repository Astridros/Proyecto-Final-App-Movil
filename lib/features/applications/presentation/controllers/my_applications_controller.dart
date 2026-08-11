import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';
import '../../data/providers/applications_data_providers.dart';
import '../../domain/repositories/applications_repository.dart';
import 'my_applications_state.dart';

class MyApplicationsController
    extends Notifier<MyApplicationsState> {
  late final ApplicationsRepository _repository;

  @override
  MyApplicationsState build() {
    _repository = ref.watch(
      applicationsRepositoryProvider,
    );

    return MyApplicationsState.initial();
  }

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final applications =
      await _repository.getMyApplications();

      state = state.copyWith(
        applications: applications,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );
    } finally {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = state.copyWith(
      isRefreshing: true,
      error: null,
    );

    try {
      final applications =
      await _repository.getMyApplications();

      state = state.copyWith(
        applications: applications,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );
    } finally {
      state = state.copyWith(
        isRefreshing: false,
      );
    }
  }

  AppException _toAppException(Object error) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message:
      'Ocurrió un error inesperado al cargar tus aplicaciones.',
      cause: error,
    );
  }
}