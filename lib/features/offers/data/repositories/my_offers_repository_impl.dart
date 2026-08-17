import '../../domain/entities/offer.dart';
import '../../domain/repositories/my_offers_repository.dart';
import '../datasources/my_offers_remote_datasource.dart';

class MyOffersRepositoryImpl implements MyOffersRepository {
  const MyOffersRepositoryImpl(this._remoteDataSource);

  final MyOffersRemoteDataSource _remoteDataSource;

  @override
  Future<List<Offer>> getMyOffers() => _remoteDataSource.getMyOffers();

  @override
  Future<Offer> deactivateOffer(String offerId) =>
      _remoteDataSource.deactivateOffer(offerId);
}
