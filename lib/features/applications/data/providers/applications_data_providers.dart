import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_datasource.dart';
import '../repositories/applications_repository_impl.dart';

final applicationsRemoteDataSourceProvider =
Provider<ApplicationsRemoteDataSource>((ref) {
  return ApplicationsRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
  );
});

final applicationsRepositoryProvider =
Provider<ApplicationsRepository>((ref) {
  return ApplicationsRepositoryImpl(
    ref.watch(applicationsRemoteDataSourceProvider),
  );
});