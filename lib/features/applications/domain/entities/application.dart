import 'package:equatable/equatable.dart';

import 'application_answer.dart';

class Application extends Equatable {
  const Application({
    required this.id,
    required this.offerId,
    required this.applicantId,
    required this.comment,
    required this.answers,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String offerId;
  final String applicantId;
  final String comment;
  final List<ApplicationAnswer> answers;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    offerId,
    applicantId,
    comment,
    answers,
    status,
    createdAt,
    updatedAt,
  ];
}
