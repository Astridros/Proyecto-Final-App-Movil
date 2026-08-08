import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/secure_storage_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/remembered_credentials_storage.dart';
import '../repositories/auth_repository_impl.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final rememberedCredentialsStorageProvider =
    Provider<RememberedCredentialsStorage>((ref) {
      return SecureRememberedCredentialsStorage(
        ref.watch(secureStorageProvider),
      );
    });

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
  );
});
