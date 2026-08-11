import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/payment.dart';

const _unset = Object();

class MyPaymentsState extends Equatable {
  MyPaymentsState({
    required this.isInitialLoading,
    required this.isRefreshing,
    required List<Payment> payments,
    required this.error,
  }) : payments = List.unmodifiable(payments);

  factory MyPaymentsState.initial() {
    return MyPaymentsState(
      isInitialLoading: false,
      isRefreshing: false,
      payments: const [],
      error: null,
    );
  }

  final bool isInitialLoading;
  final bool isRefreshing;
  final List<Payment> payments;
  final AppException? error;

  bool get hasError => error != null;
  bool get hasPayments => payments.isNotEmpty;
  bool get isEmpty =>
      !isInitialLoading && !isRefreshing && !hasError && payments.isEmpty;

  MyPaymentsState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    List<Payment>? payments,
    Object? error = _unset,
  }) {
    return MyPaymentsState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      payments: payments ?? this.payments,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    isRefreshing,
    payments,
    error,
  ];
}
