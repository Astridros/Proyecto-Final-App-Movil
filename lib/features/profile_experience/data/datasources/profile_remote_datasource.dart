import '../../../../core/network/api_client.dart';

import '../models/profile_model.dart';
import '../models/experience_json_parse_utils.dart';

abstract class ProfileRemoteDataSource {

  Future<ProfileModel> getProfile();

  Future<void> updateProfile(
    ProfileModel profile,
  );
}

class OcupaBackendProfileRemoteDataSource
    implements ProfileRemoteDataSource {

  const OcupaBackendProfileRemoteDataSource(
    this._apiClient,
  );

  final ApiClient _apiClient;

  @override
  Future<ProfileModel> getProfile() async {

    final response = await _apiClient.get<Object?>(
      '/me',
    );

    final map = requireJsonMap(
      response.data,
      'La respuesta',
    );

    if (map['ok'] != true) {
      throw Exception('No fue posible obtener el perfil.');
    }

    final data = map['data'];

    if (data is! Map) {
      throw Exception('Perfil inválido.');
    }

    return ProfileModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  @override
  Future<void> updateProfile(
    ProfileModel profile,
  ) async {

    await _apiClient.put<Object?>(
      '/me/profile',
      data: profile.toUpdateJson(),
    );
  }
}