import '../../domain/entities/experience.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasources/experience_remote_datasource.dart';
import '../models/experience_model.dart';

class ExperienceRepositoryImpl implements ExperienceRepository{
  const ExperienceRepositoryImpl(
    this._remoteDataSource,
  );

  final ExperienceRemoteDataSource _remoteDataSource;

  @override
  Future<List<Experience>> getExperiences({
    bool forceRefresh = false,
  }) {
    return _remoteDataSource.getExperiences(
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<void> createExperience(
    Experience experience,
  ){
    return _remoteDataSource.createExperience(
      ExperienceModel.fromEntity(experience),
    );
  }

  @override
  Future<void> deleteExperience(String id) {
    return _remoteDataSource.deleteExperience(id);
  }
}