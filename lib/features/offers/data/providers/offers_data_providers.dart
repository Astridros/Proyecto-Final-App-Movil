import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/offers_repository.dart';
import '../../domain/repositories/my_offers_repository.dart';
import '../datasources/my_offers_remote_datasource.dart';
import '../datasources/offers_remote_datasource.dart';
import '../repositories/offers_repository_impl.dart';
import '../repositories/my_offers_repository_impl.dart';

final offersRemoteDataSourceProvider = Provider<OffersRemoteDataSource>((ref) {
  return OffersRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final offersRepositoryProvider = Provider<OffersRepository>((ref) {
  return OffersRepositoryImpl(ref.watch(offersRemoteDataSourceProvider));
});

final myOffersRemoteDataSourceProvider = Provider<MyOffersRemoteDataSource>(
  (ref) => MyOffersRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final myOffersRepositoryProvider = Provider<MyOffersRepository>(
  (ref) => MyOffersRepositoryImpl(ref.watch(myOffersRemoteDataSourceProvider)),
);
