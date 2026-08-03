import '../../../offers/data/models/json_parse_utils.dart';
import '../../domain/entities/application.dart';
import 'application_answer_model.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.offerId,
    required super.applicantId,
    required super.comment,
    required super.answers,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ApplicationModel.fromJson(JsonMap json) {
    return ApplicationModel(
      id: requiredString(json, 'id', 'La aplicacion'),
      offerId: requiredString(json, 'offerId', 'La aplicacion'),
      applicantId: optionalString(json, 'applicantId'),
      comment: optionalString(json, 'comment'),
      answers: parseList(
        json['answers'],
        ApplicationAnswerModel.fromJson,
        context: 'Las respuestas de la aplicacion',
      ),
      status: optionalString(json, 'status'),
      createdAt: optionalDate(json, 'createdAt'),
      updatedAt: optionalDate(json, 'updatedAt'),
    );
  }
}
