import '../../domain/entities/offer_question.dart';
import 'json_parse_utils.dart';

class OfferQuestionModel extends OfferQuestion {
  const OfferQuestionModel({
    required super.id,
    required super.label,
    required super.type,
    required super.required,
  });

  factory OfferQuestionModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'La pregunta de la oferta');

    return OfferQuestionModel(
      id: requiredString(map, 'id', 'La pregunta de la oferta'),
      label: requiredString(map, 'label', 'La pregunta de la oferta'),
      type: requiredString(map, 'type', 'La pregunta de la oferta'),
      required: boolValue(map, 'required'),
    );
  }
}
