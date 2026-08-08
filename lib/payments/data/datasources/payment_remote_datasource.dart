import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<Payment> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  });

  Future<List<PaymentModel>> getPayments();
}

class OcupaBackendPaymentRemoteDataSource
    implements PaymentRemoteDataSource {

  const OcupaBackendPaymentRemoteDataSource(
    this._apiClient,
  );

  final ApiClient _apiClient;

  @override
  Future<Payment> createPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  }) async {

    final response = await _apiClient.post<Object?>(
      '/payments',
      data: {
        'cardNumber': cardNumber,
        'cvv': cvv,
        'expMonth': expMonth,
        'expYear': expYear,
        'cardholder': cardholder,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(
        'La respuesta del pago no es válida.',
      );
    }

    final map = Map<String, dynamic>.from(data);

    if (map['ok'] != true) {
      throw Exception(
        map['error']?.toString() ??
            'El pago no fue aprobado.',
      );
    }

    final paymentData = map['data'];

    if (paymentData is! Map) {
      throw Exception(
        'No se recibieron los datos del pago.',
      );
    }

    return PaymentModel.fromJson(
      Map<String, dynamic>.from(paymentData),
    );
  }

  @override
  Future<List<PaymentModel>> getPayments() async {

    final response = await _apiClient.get<Object?>(
      '/payments',
    );

    final data = response.data;

    if (data is! Map) {
      return const [];
    }

    final map = Map<String, dynamic>.from(data);

    if (map['ok'] != true) {
      return const [];
    }

    final payments = map['data'];

    if (payments is! List) {
      return const [];
    }

    return List.unmodifiable(
      payments
          .whereType<Map>()
          .map(
            (payment) => PaymentModel.fromJson(
              Map<String, dynamic>.from(payment),
            ),
          ),
    );
  }
}