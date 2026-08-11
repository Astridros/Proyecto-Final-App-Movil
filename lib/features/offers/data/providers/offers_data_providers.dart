import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_remote_datasource.dart';
import '../repositories/offers_repository_impl.dart';

final offersRemoteDataSourceProvider =
Provider<OffersRemoteDataSource>((ref) {
  return OffersRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
  );
});

final offersRepositoryProvider =
Provider<OffersRepository>((ref) {
  return OffersRepositoryImpl(
    ref.watch(
      offersRemoteDataSourceProvider,
    ),
  );
});