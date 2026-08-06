import '../../domain/entities/apply_offer_answer.dart';
import '../../domain/entities/apply_offer_result.dart';
import '../../domain/entities/job_type.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/offer_like_result.dart';
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

  @override
  Future<Offer> getOfferById(String id) {
    return _remoteDataSource.getOfferById(id);
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) {
    return _remoteDataSource.applyToOffer(
      offerId: offerId,
      comment: comment,
      answers: answers,
    );
  }

  @override
  Future<OfferLikeResult> likeOffer(String offerId) {
    return _remoteDataSource.likeOffer(offerId);
  }

  @override
  Future<OfferLikeResult> unlikeOffer(String offerId) {
    return _remoteDataSource.unlikeOffer(offerId);
  }

  @override
  Future<List<Offer>> getMyLikedOffers() {
    return _remoteDataSource.getMyLikedOffers();
  }
}
