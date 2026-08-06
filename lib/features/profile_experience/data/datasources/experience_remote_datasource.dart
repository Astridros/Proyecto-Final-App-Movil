import 'package:ocupa2/features/profile_experience/domain/entities/experience.dart';

import '../../../../core/network/api_client.dart';
import '../models/experience_model.dart';
import '../models/experience_json_parse_utils.dart';

abstract class ExperienceRemoteDataSource {
  Future<List<Experience>> getExperiences({
    bool forceRefresh = false,
  });

  Future<void> createExperience(
    ExperienceModel experience,
  );
}

class OcupaBackendExperienceRemoteDataSource implements ExperienceRemoteDataSource {
  const OcupaBackendExperienceRemoteDataSource(
    this._apiClient,
  );

  final ApiClient _apiClient;

  @override
  Future<List<Experience>> getExperiences({
    bool forceRefresh = false,
  }) async{
    final response = await _apiClient.get<Object?>(
      '/experiences',
    );

    final map = requireJsonMap(
      response.data,
      'La respuesta',
    );

    if (map['ok'] != true){
      return const [];
    }

    final data = map['data'];

    if (data is! List){
      return const [];
    }

    return List.unmodifiable(
      data.whereType<Map>().map(
        (e) => ExperienceModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      ),
    );
  }

  @override
  Future<void> createExperience(
    ExperienceModel experience,
  ) async{
    await _apiClient.post<Object?>(
      '/experiences',
      data: experience.toJson(),
    );
  }
}