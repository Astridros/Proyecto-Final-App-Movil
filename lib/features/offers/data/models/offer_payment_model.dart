import '../../domain/entities/offer_payment.dart';
import 'json_parse_utils.dart';

class OfferPaymentModel extends OfferPayment {
  const OfferPaymentModel({
    required super.amount,
    required super.currency,
    required super.period,
  });

  factory OfferPaymentModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'El pago de la oferta');

    return OfferPaymentModel(
      amount: doubleValue(map, 'amount'),
      currency: optionalString(map, 'currency'),
      period: optionalString(map, 'period'),
    );
  }
}
