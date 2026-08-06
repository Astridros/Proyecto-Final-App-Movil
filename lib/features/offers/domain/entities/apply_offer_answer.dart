import 'package:equatable/equatable.dart';

class ApplyOfferAnswer extends Equatable {
  const ApplyOfferAnswer({required this.questionId, required this.value});

  final String questionId;
  final String value;

  @override
  List<Object?> get props => [questionId, value];
}
