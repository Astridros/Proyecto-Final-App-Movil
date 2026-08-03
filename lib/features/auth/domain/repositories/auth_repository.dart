import '../entities/auth_session_result.dart';

abstract interface class AuthRepository {
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  });

  Future<AuthSessionResult> login({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  });
}
