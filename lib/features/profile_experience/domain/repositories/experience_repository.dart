import '../entities/experience.dart';

abstract class ExperienceRepository {
  Future<List<Experience>> getExperiences({
    bool forceRefresh = false,
  });

  Future<void> createExperience(
    Experience experience,
  );
}