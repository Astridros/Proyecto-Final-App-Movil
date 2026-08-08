import 'package:equatable/equatable.dart';

import 'offer_question.dart';

class CreateOfferRequest extends Equatable {
  const CreateOfferRequest({
    required this.jobTypeKey,
    required this.contractType,
    required this.description,
    required this.address,
    required this.photo,
    required this.latitude,
    required this.longitude,
    required this.amount,
    required this.currency,
    required this.deadline,
    required this.paymentId,
    required this.customAnswers,
    required this.questions,
  });

  final String jobTypeKey;
  final String contractType;
  final String description;
  final String address;
  final String photo;
  final double latitude;
  final double longitude;
  final double amount;
  final String currency;
  final DateTime deadline;
  final String paymentId;
  final Map<String, Object?> customAnswers;
  final List<OfferQuestion> questions;

  @override
  List<Object?> get props => [
    jobTypeKey,
    contractType,
    description,
    address,
    photo,
    latitude,
    longitude,
    amount,
    currency,
    deadline,
    paymentId,
    customAnswers,
    questions,
  ];
}
