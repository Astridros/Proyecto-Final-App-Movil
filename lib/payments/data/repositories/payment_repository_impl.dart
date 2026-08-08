import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl
    implements PaymentRepository {

  const PaymentRepositoryImpl(
    this._remoteDataSource,
  );

  final PaymentRemoteDataSource _remoteDataSource;

  @override
  Future<Payment> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  }) {
    return _remoteDataSource.createPayment(
      cardNumber: cardNumber,
      cvv: cvv,
      expMonth: expMonth,
      expYear: expYear,
      cardholder: cardholder,
    );
  }

  @override
  Future<List<Payment>> getPayments() {
    return _remoteDataSource.getPayments();
  }
}