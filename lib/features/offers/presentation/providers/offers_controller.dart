import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';
import '../../../../core/errors/validation_exception.dart';
import '../../data/providers/offers_data_providers.dart';
import '../../domain/constants/contract_types.dart';
import '../../domain/entities/job_type.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/offers_repository.dart';
import 'offers_state.dart';

class OffersController extends Notifier<OffersState> {
  late final OffersRepository _repository;
  int _filterRequestId = 0;

  @override
  OffersState build() {
    _repository = ref.watch(offersRepositoryProvider);
    return OffersState.initial();
  }

  Future<void> loadInitial() async {
    if (state.isInitialLoading) {
      return;
    }

    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final results = await Future.wait<Object>([
        _repository.getJobTypes(),
        _repository.getOffers(),
      ]);
      final jobTypes = results[0] as List<JobType>;
      final offers = results[1] as List<Offer>;

      state = state.copyWith(
        jobTypes: _activeJobTypes(jobTypes),
        offers: offers,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final results = await Future.wait<Object>([
        _repository.getJobTypes(),
        _repository.getOffers(
          jobTypeKey: state.selectedJobTypeKey,
          contractType: state.selectedContractType,
        ),
      ]);
      final jobTypes = results[0] as List<JobType>;
      final offers = results[1] as List<Offer>;

      state = state.copyWith(
        jobTypes: _activeJobTypes(jobTypes),
        offers: offers,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  Future<void> changeJobType(String? jobTypeKey) async {
    final normalizedJobTypeKey = _normalizeFilter(jobTypeKey);
    if (normalizedJobTypeKey == state.selectedJobTypeKey) {
      return;
    }

    await _loadOffersForFilters(jobTypeKey: normalizedJobTypeKey);
  }

  Future<void> changeContractType(String? contractType) async {
    final normalizedContractType = _normalizeFilter(contractType);
    if (normalizedContractType != null &&
        !ContractTypes.isValid(normalizedContractType)) {
      state = state.copyWith(
        error: const ValidationException(
          message: 'El tipo de contrato seleccionado no es válido.',
        ),
      );
      return;
    }

    if (normalizedContractType == state.selectedContractType) {
      return;
    }

    await _loadOffersForFilters(contractType: normalizedContractType);
  }

  Future<void> clearFilters() async {
    if (!state.hasActiveFilters) {
      return;
    }

    await _loadOffersForFilters(jobTypeKey: null, contractType: null);
  }

  void clearError() {
    if (state.error == null) {
      return;
    }

    state = state.copyWith(error: null);
  }

  Future<void> _loadOffersForFilters({
    Object? jobTypeKey = _keepFilter,
    Object? contractType = _keepFilter,
  }) async {
    final nextJobTypeKey = identical(jobTypeKey, _keepFilter)
        ? state.selectedJobTypeKey
        : jobTypeKey as String?;
    final nextContractType = identical(contractType, _keepFilter)
        ? state.selectedContractType
        : contractType as String?;
    // Evita que una respuesta vieja de filtros sobrescriba la selección más reciente.
    final requestId = ++_filterRequestId;

    state = state.copyWith(
      selectedJobTypeKey: nextJobTypeKey,
      selectedContractType: nextContractType,
      isFiltering: true,
      error: null,
    );

    try {
      final offers = await _repository.getOffers(
        jobTypeKey: nextJobTypeKey,
        contractType: nextContractType,
      );

      if (requestId != _filterRequestId) {
        return;
      }

      state = state.copyWith(offers: offers, error: null);
    } catch (error) {
      if (requestId != _filterRequestId) {
        return;
      }

      state = state.copyWith(error: _toAppException(error));
    } finally {
      if (requestId == _filterRequestId) {
        state = state.copyWith(isFiltering: false);
      }
    }
  }

  List<JobType> _activeJobTypes(List<JobType> jobTypes) {
    return List.unmodifiable(jobTypes.where((jobType) => jobType.active));
  }

  String? _normalizeFilter(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  AppException _toAppException(Object error) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: 'Ocurrió un error inesperado.',
      cause: error,
    );
  }
}

const _keepFilter = Object();
