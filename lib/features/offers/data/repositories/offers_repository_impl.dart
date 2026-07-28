import '../../domain/entities/job_type.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_remote_datasource.dart';

class OffersRepositoryImpl implements OffersRepository {
  const OffersRepositoryImpl(this._remoteDataSource);

  final OffersRemoteDataSource _remoteDataSource;

  @override
  Future<List<JobType>> getJobTypes() {
    return _remoteDataSource.getJobTypes();
  }

  @override
  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType}) {
    return _remoteDataSource.getOffers(
      jobTypeKey: jobTypeKey,
      contractType: contractType,
    );
  }
}
