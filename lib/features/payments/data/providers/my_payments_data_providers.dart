import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/my_payments_repository.dart';
import '../datasources/my_payments_remote_datasource.dart';
import '../repositories/my_payments_repository_impl.dart';

final myPaymentsRemoteDataSourceProvider = Provider<MyPaymentsRemoteDataSource>(
  (ref) {
    return MyPaymentsRemoteDataSourceImpl(ref.watch(apiClientProvider));
  },
);

final myPaymentsRepositoryProvider = Provider<MyPaymentsRepository>((ref) {
  return MyPaymentsRepositoryImpl(ref.watch(myPaymentsRemoteDataSourceProvider));
});
