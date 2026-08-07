import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasources/experience_remote_datasource.dart';
import '../repositories/experience_repository_impl.dart';

final experienceRemoteDataSourceProvider = Provider<ExperienceRemoteDataSource>((ref){
  return OcupaBackendExperienceRemoteDataSource(
    ref.watch(apiClientProvider),
  );
});

final experienceRepositoryProvider = Provider<ExperienceRepository>((ref){
  return ExperienceRepositoryImpl(
    ref.watch(experienceRemoteDataSourceProvider),
  );
});