import '../../domain/entities/apply_offer_answer.dart';
import 'apply_offer_answer_model.dart';

class ApplyOfferRequestModel {
  const ApplyOfferRequestModel({required this.comment, required this.answers});

  final String comment;
  final List<ApplyOfferAnswer> answers;

  Map<String, Object?> toJson() {
    return {
      'comment': comment,
      'answers': answers
          .map((answer) => ApplyOfferAnswerModel.fromEntity(answer).toJson())
          .toList(growable: false),
    };
  }
}
