import '../../domain/entities/create_offer_request.dart';

class CreateOfferRequestModel extends CreateOfferRequest {
  const CreateOfferRequestModel({
    required super.jobTypeKey,
    required super.contractType,
    required super.description,
    required super.address,
    required super.photo,
    required super.location,
    required super.amount,
    required super.currency,
    required super.deadline,
    required super.paymentId,
    required super.customAnswers,
    required super.questions,
  });

  factory CreateOfferRequestModel.fromEntity(CreateOfferRequest request) {
    return CreateOfferRequestModel(
      jobTypeKey: request.jobTypeKey,
      contractType: request.contractType,
      description: request.description,
      address: request.address,
      photo: request.photo,
      location: request.location,
      amount: request.amount,
      currency: request.currency,
      deadline: request.deadline,
      paymentId: request.paymentId,
      customAnswers: request.customAnswers,
      questions: request.questions,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'jobTypeKey': jobTypeKey,
      'contractType': contractType,
      'description': description,
      'address': address,
      'photo': photo,
      'location': {'lat': location.lat, 'lng': location.lng},
      'paymentId': paymentId,
      'payment': {'amount': amount, 'currency': currency},
      'deadline': _dateOnly(deadline),
      'customAnswers': customAnswers,
      'questions': questions
          .map(
            (question) => {
              'label': question.label,
              'type': question.type,
              'required': question.required,
              'options': question.options,
            },
          )
          .toList(growable: false),
    };
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
  }
}
