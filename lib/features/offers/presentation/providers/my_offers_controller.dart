import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/offers_data_providers.dart';
import '../../domain/repositories/offers_repository.dart';
import 'my_offers_state.dart';

class MyOffersController
    extends Notifier<MyOffersState> {
  late final OffersRepository _repository;

  @override
  MyOffersState build() {
    _repository = ref.watch(
      offersRepositoryProvider,
    );

    return MyOffersState.initial();
  }

  Future<void> loadInitial() async {
    if (state.isInitialLoading) {
      return;
    }

    state = state.copyWith(
      isInitialLoading: true,
      error: null,
    );

    try {
      final offers =
      await _repository.getMyOffers();

      state = state.copyWith(
        offers: offers,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );
    } finally {
      state = state.copyWith(
        isInitialLoading: false,
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
      final offers =
      await _repository.getMyOffers();

      state = state.copyWith(
        offers: offers,
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

  void clearError() {
    if (state.error == null) {
      return;
    }

    state = state.copyWith(
      error: null,
    );
  }

  AppException _toAppException(
      Object error,
      ) {
    return ErrorMapper.fromObject(error);
  }
}
