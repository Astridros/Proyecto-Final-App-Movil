import 'package:equatable/equatable.dart';

class ApplicationAnswer extends Equatable {
  const ApplicationAnswer({required this.questionId, required this.value});

  final String questionId;
  final String value;

  @override
  List<Object?> get props => [questionId, value];
}
