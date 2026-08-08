import '../../domain/entities/offer.dart';
import 'json_parse_utils.dart';
import 'offer_location_model.dart';
import 'offer_payment_model.dart';
import 'offer_question_model.dart';

class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    super.ownerId,
    required super.jobTypeKey,
    required super.jobTypeName,
    required super.contractType,
    required super.description,
    required super.address,
    required super.location,
    required super.payment,
    required super.photo,
    required super.customAnswers,
    required super.questions,
    required super.status,
    required super.applicantsCount,
    required super.likesCount,
    required super.createdAt,
    required super.updatedAt,
    required super.isIdentityRevealed,
    required super.likedByMe,
    super.deadline,
    super.paymentId,
  });

  factory OfferModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'La oferta');

    return OfferModel(
      id: requiredString(map, 'id', 'La oferta'),
      ownerId: _nullableString(map['ownerId']),
      jobTypeKey: requiredString(map, 'jobTypeKey', 'La oferta'),
      jobTypeName: requiredString(map, 'jobTypeName', 'La oferta'),
      contractType: optionalString(map, 'contractType'),
      description: optionalString(map, 'description'),
      address: optionalString(map, 'address'),
      location: OfferLocationModel.fromJson(map['location']),
      payment: OfferPaymentModel.fromJson(map['payment']),
      photo: optionalString(map, 'photo'),
      deadline: optionalDate(map, 'deadline'),
      customAnswers: stringObjectMap(map['customAnswers'], 'customAnswers'),
      questions: parseList(
        map['questions'],
        OfferQuestionModel.fromJson,
        context: 'questions',
      ),
      status: optionalString(map, 'status'),
      applicantsCount: intValue(map, 'applicantsCount'),
      likesCount: intValue(map, 'likesCount'),
      createdAt: requiredDate(map, 'createdAt', 'La oferta'),
      updatedAt: requiredDate(map, 'updatedAt', 'La oferta'),
      isIdentityRevealed: boolValue(map, 'isIdentityRevealed'),
      likedByMe: boolValue(map, 'likedByMe'),
      paymentId: _nullableString(map['paymentId']),
    );
  }

  static String? _nullableString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }
}
