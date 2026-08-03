abstract interface class ChangePasswordRepository {
  Future<void> changePassword({required String password});
}
