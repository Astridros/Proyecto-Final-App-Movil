import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/update_profile_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Profile> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  }) {
    return _remoteDataSource.updateProfile(
      UpdateProfileRequestModel(
        firstName: firstName,
        lastName: lastName,
        cedula: cedula,
        gender: gender,
        birthDate: birthDate,
      ),
    );
  }
}
