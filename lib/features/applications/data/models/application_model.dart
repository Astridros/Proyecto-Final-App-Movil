import '../../../offers/data/models/json_parse_utils.dart';
import '../../../offers/data/models/offer_model.dart';
import '../../../offers/domain/entities/offer.dart';
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
    super.rating,
    super.offer,
  });

  factory ApplicationModel.fromJson(JsonMap json) {
    Offer? offer;

    final offerJson = json['offer'];

    if (offerJson != null) {
      offer = OfferModel.fromJson(offerJson);
    }

    return ApplicationModel(
      id: requiredString(
        json,
        'id',
        'La aplicación',
      ),
      offerId: requiredString(
        json,
        'offerId',
        'La aplicación',
      ),
      applicantId: optionalString(
        json,
        'applicantId',
      ),
      comment: optionalString(
        json,
        'comment',
      ),
      answers: parseList(
        json['answers'],
        ApplicationAnswerModel.fromJson,
        context: 'Las respuestas de la aplicación',
      ),
      rating: json['rating'],
      status: optionalString(
        json,
        'status',
      ),
      createdAt: optionalDate(
        json,
        'createdAt',
      ),
      updatedAt: optionalDate(
        json,
        'updatedAt',
      ),
      offer: offer,
    );
  }
}