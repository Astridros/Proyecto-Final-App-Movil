import '../../domain/entities/apply_offer_answer.dart';

class ApplyOfferAnswerModel extends ApplyOfferAnswer {
  const ApplyOfferAnswerModel({
    required super.questionId,
    required super.value,
  });

  factory ApplyOfferAnswerModel.fromEntity(ApplyOfferAnswer answer) {
    return ApplyOfferAnswerModel(
      questionId: answer.questionId,
      value: answer.value,
    );
  }

  Map<String, Object?> toJson() {
    return {'questionId': questionId, 'value': value};
  }
}
