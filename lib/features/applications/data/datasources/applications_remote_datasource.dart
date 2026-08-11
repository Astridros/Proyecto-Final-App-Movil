import '../../../../core/network/api_client.dart';
import '../../../offers/data/models/api_list_response.dart';
import '../../domain/entities/application.dart';
import '../models/application_model.dart';

abstract class ApplicationsRemoteDataSource {
  Future<List<Application>> getMyApplications();
}

class ApplicationsRemoteDataSourceImpl implements ApplicationsRemoteDataSource {
  const ApplicationsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Application>> getMyApplications() async {
    final response = await _apiClient.get<Object>('/me/applications');
    return ApiListResponse<Application>.fromJson(
      response.data,
      ApplicationModel.fromJson,
    ).data;
  }
}
