import '../../domain/entities/offer_location.dart';
import 'json_parse_utils.dart';

class OfferLocationModel extends OfferLocation {
  const OfferLocationModel({required super.lat, required super.lng});

  factory OfferLocationModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'La ubicación de la oferta');

    return OfferLocationModel(
      lat: doubleValue(map, 'lat'),
      lng: doubleValue(map, 'lng'),
    );
  }
}
