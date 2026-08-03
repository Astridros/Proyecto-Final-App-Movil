import '../entities/job_type.dart';
import '../entities/apply_offer_answer.dart';
import '../entities/apply_offer_result.dart';
import '../entities/offer.dart';

abstract interface class OffersRepository {
  Future<List<JobType>> getJobTypes();

  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType});

  Future<Offer> getOfferById(String id);

  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  });
}
