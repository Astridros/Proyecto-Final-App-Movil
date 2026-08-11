import '../entities/offer.dart';

abstract interface class MyOffersRepository {
  Future<List<Offer>> getMyOffers();

  Future<Offer> deactivateOffer(String offerId);
}
