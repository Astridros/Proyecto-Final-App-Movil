class Payment {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String concept;
  final String cardLast4;
  final String cardholder;
  final String reference;
  final bool consumed;
  final String? offerId;
  final String? declineReason;
  final String createdAt;

  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.concept,
    required this.cardLast4,
    required this.cardholder,
    required this.reference,
    required this.consumed,
    required this.offerId,
    required this.declineReason,
    required this.createdAt,
  });
}