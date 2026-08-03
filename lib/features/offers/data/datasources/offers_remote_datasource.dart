import '../../../../core/network/api_client.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/apply_offer_answer.dart';
import '../../domain/entities/apply_offer_result.dart';
import '../../domain/entities/job_type.dart';
import '../../domain/entities/offer.dart';
import '../models/apply_offer_request_model.dart';
import '../models/apply_offer_result_model.dart';
import '../models/api_list_response.dart';
import '../models/job_type_model.dart';
import '../models/offer_model.dart';

abstract interface class OffersRemoteDataSource {
  Future<List<JobType>> getJobTypes();

  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType});

  Future<Offer> getOfferById(String id);

  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  });
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  const OffersRemoteDataSourceImpl(this._apiClient);

  static const _jobTypesPath = '/job-types';
  static const _offersPath = '/offers';

  final ApiClient _apiClient;

  @override
  Future<List<JobType>> getJobTypes() async {
    final response = await _apiClient.get<Object?>(_jobTypesPath);
    final parsed = ApiListResponse<JobType>.fromJson(
      response.data,
      JobTypeModel.fromJson,
    );

    return parsed.data;
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    final response = await _apiClient.get<Object?>(
      _offersPath,
      queryParameters: _buildQueryParameters(
        jobTypeKey: jobTypeKey,
        contractType: contractType,
      ),
    );
    final parsed = ApiListResponse<Offer>.fromJson(
      response.data,
      OfferModel.fromJson,
    );

    return parsed.data;
  }

  @override
  Future<Offer> getOfferById(String id) async {
    final normalizedId = _requiredId(id, 'id');
    final response = await _apiClient.get<Object?>(
      '$_offersPath/$normalizedId',
    );
    final data = _responseData(response.data, 'La oferta');

    return OfferModel.fromJson(data);
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) async {
    final normalizedOfferId = _requiredId(offerId, 'offerId');
    final request = ApplyOfferRequestModel(comment: comment, answers: answers);
    final response = await _apiClient.post<Object?>(
      '$_offersPath/$normalizedOfferId/apply',
      data: request.toJson(),
    );

    return ApplyOfferResultModel.fromApiResponse(response.data);
  }

  Map<String, dynamic>? _buildQueryParameters({
    String? jobTypeKey,
    String? contractType,
  }) {
    final query = <String, dynamic>{};
    final normalizedJobTypeKey = jobTypeKey?.trim();
    final normalizedContractType = contractType?.trim();

    if (normalizedJobTypeKey != null && normalizedJobTypeKey.isNotEmpty) {
      query['jobTypeKey'] = normalizedJobTypeKey;
    }

    if (normalizedContractType != null && normalizedContractType.isNotEmpty) {
      query['contractType'] = normalizedContractType;
    }

    return query.isEmpty ? null : query;
  }

  String _requiredId(String id, String fieldName) {
    final normalized = id.trim();
    if (normalized.isEmpty) {
      throw ApiException(message: 'El campo "$fieldName" es requerido.');
    }

    return normalized;
  }

  Object? _responseData(Object? json, String context) {
    if (json is! Map) {
      throw ApiException(message: '$context debe ser un objeto JSON válido.');
    }

    if (json['ok'] != true) {
      throw ApiException(message: 'No fue posible cargar la oferta.');
    }

    return json['data'];
  }
}
