import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl
    implements ProfileRepository {

  const ProfileRepositoryImpl(
    this._remoteDataSource,
  );

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Profile> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(
    Profile profile,
  ) {
    return _remoteDataSource.updateProfile(
      ProfileModel.fromEntity(profile),
    );
  }
}