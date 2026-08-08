import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Payment> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  });

  Future<List<Payment>> getPayments();
}