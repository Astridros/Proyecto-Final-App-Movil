import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile();

  Future<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  });
}
