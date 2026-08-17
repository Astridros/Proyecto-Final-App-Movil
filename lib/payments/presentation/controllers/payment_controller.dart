import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';

import '../../data/providers/payment_data_providers.dart';
import '../../domain/repositories/payment_repository.dart';

import 'payment_state.dart';

class PaymentController
    extends Notifier<PaymentState> {

  late final PaymentRepository _repository;

  @override
  PaymentState build() {
    _repository = ref.watch(
      paymentRepositoryProvider,
    );

    return PaymentState.initial();
  }

  Future<void> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  }) async {

    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearPayment: true,
    );

    try {

      final payment =
          await _repository.createPayment(
        cardNumber: cardNumber,
        cvv: cvv,
        expMonth: expMonth,
        expYear: expYear,
        cardholder: cardholder,
      );

      state = state.copyWith(
        isLoading: false,
        payment: payment,
        clearError: true,
      );

    } catch (error) {

      state = state.copyWith(
        isLoading: false,
        error: _toAppException(error).message,
      );
    }
  }

  AppException _toAppException(
    Object error,
  ) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: 'Ocurrió un error inesperado.',
      cause: error,
    );
  }
}