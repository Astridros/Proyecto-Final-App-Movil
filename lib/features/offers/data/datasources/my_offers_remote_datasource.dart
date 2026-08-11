import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/offer.dart';
import '../models/api_list_response.dart';
import '../models/offer_model.dart';

abstract interface class MyOffersRemoteDataSource {
  Future<List<Offer>> getMyOffers();

  Future<Offer> deactivateOffer(String offerId);
}

class MyOffersRemoteDataSourceImpl implements MyOffersRemoteDataSource {
  const MyOffersRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Offer>> getMyOffers() async {
    final response = await _apiClient.get<Object?>('/me/offers');
    if (kDebugMode) {
      debugPrint(
        '[MyOffers] GET ${response.requestOptions.uri} -> ${response.statusCode}',
      );
    }
    final parsed = ApiListResponse<Offer>.fromJson(
      response.data,
      OfferModel.fromJson,
    );
    if (kDebugMode) {
      debugPrint('[MyOffers] Ofertas recibidas: ${parsed.data.length}');
    }
    return parsed.data;
  }

  @override
  Future<Offer> deactivateOffer(String offerId) async {
    final normalizedId = offerId.trim();
    if (normalizedId.isEmpty) {
      throw const ApiException(message: 'El identificador es obligatorio.');
    }
    final response = await _apiClient.post<Object?>(
      '/offers/$normalizedId/deactivate',
    );
    final json = response.data;
    if (json is! Map || json['ok'] != true) {
      throw const ApiException(message: 'No fue posible desactivar la oferta.');
    }
    return OfferModel.fromJson(json['data']);
  }
}
