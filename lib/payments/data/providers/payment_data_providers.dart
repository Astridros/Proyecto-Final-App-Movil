import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';

import '../datasources/payment_remote_datasource.dart';
import '../repositories/payment_repository_impl.dart';

import '../../domain/repositories/payment_repository.dart';

final paymentRemoteDataSourceProvider =
    Provider<PaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return OcupaBackendPaymentRemoteDataSource(
    apiClient,
  );
});

final paymentRepositoryProvider =
    Provider<PaymentRepository>((ref) {
  final remoteDataSource =
      ref.watch(paymentRemoteDataSourceProvider);

  return PaymentRepositoryImpl(
    remoteDataSource,
  );
});