import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';
import '../../data/providers/applications_data_providers.dart';
import '../../domain/repositories/applications_repository.dart';
import 'offer_applications_state.dart';

class OfferApplicationsController
    extends Notifier<OfferApplicationsState> {
  OfferApplicationsController(
      this.offerId,
      );

  final String offerId;

  late final ApplicationsRepository _repository;

  @override
  OfferApplicationsState build() {
    _repository = ref.watch(
      applicationsRepositoryProvider,
    );

    return OfferApplicationsState.initial();
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
      await _repository.getOfferApplications(
        offerId.trim(),
      );

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
      await _repository.getOfferApplications(
        offerId.trim(),
      );

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

  Future<bool> updateStatus({
    required String applicationId,
    required String status,
  }) async {
    if (state.isUpdating) {
      return false;
    }

    state = state.copyWith(
      isUpdating: true,
      updatingApplicationId: applicationId,
      error: null,
    );

    try {
      await _repository.updateApplication(
        applicationId: applicationId,
        status: status,
      );

      await _reloadApplications();

      return true;
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );

      return false;
    } finally {
      state = state.copyWith(
        isUpdating: false,
        updatingApplicationId: null,
      );
    }
  }

  Future<bool> updateRating({
    required String applicationId,
    required int rating,
  }) async {
    if (state.isUpdating) {
      return false;
    }

    if (rating < 1 || rating > 5) {
      return false;
    }

    state = state.copyWith(
      isUpdating: true,
      updatingApplicationId: applicationId,
      error: null,
    );

    try {
      await _repository.updateApplication(
        applicationId: applicationId,
        rating: rating,
      );

      await _reloadApplications();

      return true;
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );

      return false;
    } finally {
      state = state.copyWith(
        isUpdating: false,
        updatingApplicationId: null,
      );
    }
  }

  Future<bool> selectWinner({
    required String applicationId,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  }) async {
    if (state.isUpdating) {
      return false;
    }

    state = state.copyWith(
      isUpdating: true,
      updatingApplicationId: applicationId,
      error: null,
    );

    try {
      await _repository.updateApplication(
        applicationId: applicationId,
        status: 'winner',
        salary: salary,
        currency: currency,
        startDate: startDate,
        duration: duration,
      );

      await _reloadApplications();

      return true;
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );

      return false;
    } finally {
      state = state.copyWith(
        isUpdating: false,
        updatingApplicationId: null,
      );
    }
  }

  Future<void> _reloadApplications() async {
    final applications =
    await _repository.getOfferApplications(
      offerId.trim(),
    );

    state = state.copyWith(
      applications: applications,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(
      error: null,
    );
  }

  AppException _toAppException(
      Object error,
      ) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message:
      'Ocurrió un error al administrar el postulante.',
      cause: error,
    );
  }
}