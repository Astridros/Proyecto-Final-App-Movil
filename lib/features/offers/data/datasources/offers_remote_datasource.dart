import '../../../../core/network/api_client.dart';
import '../../domain/entities/job_type.dart';
import '../../domain/entities/offer.dart';
import '../models/api_list_response.dart';
import '../models/job_type_model.dart';
import '../models/offer_model.dart';

abstract interface class OffersRemoteDataSource {
  Future<List<JobType>> getJobTypes();

  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType});
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
}
