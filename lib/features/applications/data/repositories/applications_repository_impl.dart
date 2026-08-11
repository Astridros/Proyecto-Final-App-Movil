import '../../domain/entities/application.dart';
import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_datasource.dart';

class ApplicationsRepositoryImpl
    implements ApplicationsRepository {
  const ApplicationsRepositoryImpl(
      this._remoteDataSource,
      );

  final ApplicationsRemoteDataSource
  _remoteDataSource;

  @override
  Future<List<Application>>
  getMyApplications() {
    return _remoteDataSource
        .getMyApplications();
  }

  @override
  Future<List<Application>>
  getOfferApplications(
      String offerId,
      ) {
    return _remoteDataSource
        .getOfferApplications(
      offerId,
    );
  }

  @override
  Future<Application> updateApplication({
    required String applicationId,
    int? rating,
    String? status,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  }) {
    return _remoteDataSource
        .updateApplication(
      applicationId: applicationId,
      rating: rating,
      status: status,
      salary: salary,
      currency: currency,
      startDate: startDate,
      duration: duration,
    );
  }
}