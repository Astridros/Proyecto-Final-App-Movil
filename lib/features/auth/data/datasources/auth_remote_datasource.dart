import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_session_result.dart';
import '../models/auth_session_result_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthSessionResult> register(RegisterRequestModel request);

  Future<AuthSessionResult> login(LoginRequestModel request);

  Future<void> forgotPassword(ForgotPasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  static const _registerPath = '/auth/register';
  static const _loginPath = '/auth/login';
  static const _forgotPasswordPath = '/auth/forgot-password';

  final ApiClient _apiClient;

  @override
  Future<AuthSessionResult> register(RegisterRequestModel request) async {
    final response = await _apiClient.post<Object?>(
      _registerPath,
      data: request.toJson(),
    );

    return AuthSessionResultModel.fromApiResponse(response.data);
  }

  @override
  Future<AuthSessionResult> login(LoginRequestModel request) async {
    final response = await _apiClient.post<Object?>(
      _loginPath,
      data: request.toJson(),
    );

    return AuthSessionResultModel.fromApiResponse(response.data);
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestModel request) async {
    await _apiClient.post<Object?>(_forgotPasswordPath, data: request.toJson());
  }
}
