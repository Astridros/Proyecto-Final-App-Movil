import '../../../../core/network/api_client.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<Profile> getProfile();

  Future<Profile> updateProfile(UpdateProfileRequestModel request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._apiClient);

  static const _profilePath = '/me';
  static const _updateProfilePath = '/me/profile';

  final ApiClient _apiClient;

  @override
  Future<Profile> getProfile() async {
    final response = await _apiClient.get<Object?>(_profilePath);

    return ProfileModel.fromApiResponse(response.data);
  }

  @override
  Future<Profile> updateProfile(UpdateProfileRequestModel request) async {
    final response = await _apiClient.put<Object?>(
      _updateProfilePath,
      data: request.toJson(),
    );

    return ProfileModel.fromApiResponse(response.data);
  }
}
