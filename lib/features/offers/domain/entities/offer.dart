import 'package:equatable/equatable.dart';

import 'offer_location.dart';
import 'offer_payment.dart';
import 'offer_question.dart';

class Offer extends Equatable {
  const Offer({
    required this.id,
    this.ownerId,
    required this.jobTypeKey,
    required this.jobTypeName,
    required this.contractType,
    required this.description,
    required this.address,
    required this.location,
    required this.payment,
    required this.photo,
    required this.customAnswers,
    required this.questions,
    required this.status,
    required this.applicantsCount,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isIdentityRevealed,
    required this.likedByMe,
    this.deadline,
    this.paymentId,
  });

  final String id;
  final String? ownerId;
  final String jobTypeKey;
  final String jobTypeName;
  final String contractType;
  final String description;
  final String address;
  final OfferLocation location;
  final OfferPayment payment;
  final String photo;
  final DateTime? deadline;
  final Map<String, Object?> customAnswers;
  final List<OfferQuestion> questions;
  final String status;
  final int applicantsCount;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isIdentityRevealed;
  final bool likedByMe;
  final String? paymentId;

  @override
  List<Object?> get props => [
    id,
    ownerId,
    jobTypeKey,
    jobTypeName,
    contractType,
    description,
    address,
    location,
    payment,
    photo,
    deadline,
    customAnswers,
    questions,
    status,
    applicantsCount,
    likesCount,
    createdAt,
    updatedAt,
    isIdentityRevealed,
    likedByMe,
    paymentId,
  ];
}
