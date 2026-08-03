import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/change_password_repository.dart';
import '../datasources/change_password_remote_datasource.dart';
import '../repositories/change_password_repository_impl.dart';

final changePasswordRemoteDataSourceProvider =
    Provider<ChangePasswordRemoteDataSource>((ref) {
      return ChangePasswordRemoteDataSourceImpl(ref.watch(apiClientProvider));
    });

final changePasswordRepositoryProvider = Provider<ChangePasswordRepository>((
  ref,
) {
  return ChangePasswordRepositoryImpl(
    ref.watch(changePasswordRemoteDataSourceProvider),
  );
});
