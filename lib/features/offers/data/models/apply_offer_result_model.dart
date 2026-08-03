import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/apply_offer_result.dart';
import 'json_parse_utils.dart';

class ApplyOfferResultModel extends ApplyOfferResult {
  const ApplyOfferResultModel({required super.id, required super.status});

  factory ApplyOfferResultModel.fromApiResponse(Object? json) {
    final response = requireJsonMap(json, 'La respuesta de aplicación');
    if (response['ok'] != true) {
      throw const ApiException(message: 'No fue posible aplicar a la oferta.');
    }

    final data = requireJsonMap(response['data'], 'La aplicación');

    return ApplyOfferResultModel(
      id: requiredString(data, 'id', 'La aplicación'),
      status: requiredString(data, 'status', 'La aplicación'),
    );
  }
}
