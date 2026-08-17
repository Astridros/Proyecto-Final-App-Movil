import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/my_payments_data_providers.dart';
import '../../domain/repositories/my_payments_repository.dart';
import 'my_payments_state.dart';

class MyPaymentsController extends Notifier<MyPaymentsState> {
  late final MyPaymentsRepository _repository;

  @override
  MyPaymentsState build() {
    _repository = ref.watch(myPaymentsRepositoryProvider);
    return MyPaymentsState.initial();
  }

  Future<void> loadPayments() async {
    if (state.isInitialLoading) {
      return;
    }

    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final payments = await _repository.getMyPayments();
      state = state.copyWith(payments: payments, error: null);
    } catch (error) {
      state = state.copyWith(error: ErrorMapper.fromObject(error));
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  // Se usa al deslizar hacia abajo. No vacia la lista mientras recarga, para
  // que la pantalla no parpadee.
  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final payments = await _repository.getMyPayments();
      state = state.copyWith(payments: payments, error: null);
    } catch (error) {
      state = state.copyWith(error: ErrorMapper.fromObject(error));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }
}
