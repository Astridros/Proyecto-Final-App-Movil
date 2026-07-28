import '../entities/job_type.dart';
import '../entities/offer.dart';

abstract interface class OffersRepository {
  Future<List<JobType>> getJobTypes();

  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType});
}
