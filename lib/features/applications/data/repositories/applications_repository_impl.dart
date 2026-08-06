import '../../domain/entities/application.dart';
import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_datasource.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  const ApplicationsRepositoryImpl(this._remoteDataSource);

  final ApplicationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Application>> getMyApplications() {
    return _remoteDataSource.getMyApplications();
  }
}
