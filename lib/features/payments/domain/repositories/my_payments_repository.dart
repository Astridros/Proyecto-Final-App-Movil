import '../entities/payment.dart';

abstract interface class MyPaymentsRepository {
  Future<List<Payment>> getMyPayments();
}
