import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/offer_like_result.dart';
import 'json_parse_utils.dart';

class OfferLikeResultModel extends OfferLikeResult {
  const OfferLikeResultModel({required super.liked, required super.likesCount});

  factory OfferLikeResultModel.fromApiResponse(Object? json) {
    final response = requireJsonMap(json, 'La respuesta de me gusta');
    if (response['ok'] != true) {
      throw ApiException(message: 'No fue posible actualizar el me gusta.');
    }

    final data = requireJsonMap(response['data'], 'El resultado de me gusta');
    final liked = data['liked'];
    final likesCount = data['likesCount'];

    if (liked is! bool) {
      throw const ApiException(
        message: 'El resultado de me gusta requiere el campo "liked".',
      );
    }

    if (likesCount is! num) {
      throw const ApiException(
        message: 'El resultado de me gusta requiere el campo "likesCount".',
      );
    }

    return OfferLikeResultModel(
      liked: liked,
      likesCount: likesCount.toInt().clamp(0, 1 << 31),
    );
  }
}
