import 'package:equatable/equatable.dart';

// Yeison Familia - modulo Mis Pagos.
// Un pago ya realizado en la plataforma. Solo lectura: este modulo lista el
// historial, no cobra. El cobro de la publicacion vive en su propio modulo.
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.concept,
    required this.status,
    required this.cardLast4,
    required this.reference,
    required this.createdAt,
    required this.declineReason,
  });

  final String id;
  final double amount;
  final String currency;
  final String concept;
  final String status;
  final String cardLast4;
  final String reference;
  final DateTime? createdAt;
  final String? declineReason;

  @override
  List<Object?> get props => [
    id,
    amount,
    currency,
    concept,
    status,
    cardLast4,
    reference,
    createdAt,
    declineReason,
  ];
}
