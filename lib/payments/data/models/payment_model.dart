import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.status,
    required super.concept,
    required super.cardLast4,
    required super.cardholder,
    required super.reference,
    required super.consumed,
    required super.offerId,
    required super.declineReason,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      concept: json['concept'] as String? ?? '',
      cardLast4: json['cardLast4'] as String? ?? '',
      cardholder: json['cardholder'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      consumed: json['consumed'] as bool? ?? false,
      offerId: json['offerId'] as String?,
      declineReason: json['declineReason'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'status': status,
      'concept': concept,
      'cardLast4': cardLast4,
      'cardholder': cardholder,
      'reference': reference,
      'consumed': consumed,
      'offerId': offerId,
      'declineReason': declineReason,
      'createdAt': createdAt,
    };
  }
}