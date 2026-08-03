import '../../../../core/errors/api_exception.dart';
import '../../../offers/data/models/json_parse_utils.dart';
import '../../domain/entities/application_answer.dart';

class ApplicationAnswerModel extends ApplicationAnswer {
  const ApplicationAnswerModel({
    required super.questionId,
    required super.value,
  });

  factory ApplicationAnswerModel.fromJson(JsonMap json) {
    final questionId = requiredString(
      json,
      'questionId',
      'La respuesta de aplicacion',
    );
    final value = json['value'];
    if (value is String) {
      return ApplicationAnswerModel(questionId: questionId, value: value);
    }

    if (value != null) {
      return ApplicationAnswerModel(
        questionId: questionId,
        value: value.toString(),
      );
    }

    throw const ApiException(
      message: 'La respuesta de aplicacion requiere el campo "value".',
    );
  }
}
