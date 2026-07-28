import 'package:equatable/equatable.dart';

class OfferPayment extends Equatable {
  const OfferPayment({
    required this.amount,
    required this.currency,
    required this.period,
  });

  final double amount;
  final String currency;
  final String period;

  @override
  List<Object?> get props => [amount, currency, period];
}
