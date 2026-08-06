import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    final result = await _remoteDataSource.register(
      RegisterRequestModel(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      ),
    );
    await _tokenStorage.saveAccessToken(result.token);

    return result;
  }

  @override
  Future<AuthSessionResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      LoginRequestModel(email: email, password: password),
    );
    await _tokenStorage.saveAccessToken(result.token);

    return result;
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) {
    return _remoteDataSource.forgotPassword(
      ForgotPasswordRequestModel(
        email: email,
        referralMatricula: referralMatricula,
      ),
    );
  }
}
