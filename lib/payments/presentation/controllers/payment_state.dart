import '../../domain/entities/payment.dart';

class PaymentState {
  final bool isLoading;
  final Payment? payment;
  final String? error;

  const PaymentState({
    required this.isLoading,
    required this.payment,
    required this.error,
  });

  factory PaymentState.initial() {
    return const PaymentState(
      isLoading: false,
      payment: null,
      error: null,
    );
  }

  PaymentState copyWith({
    bool? isLoading,
    Payment? payment,
    String? error,
    bool clearPayment = false,
    bool clearError = false,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      payment: clearPayment
          ? null
          : payment ?? this.payment,
      error: clearError
          ? null
          : error ?? this.error,
    );
  }
}