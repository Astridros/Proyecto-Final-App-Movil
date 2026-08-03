import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ocupa2/features/auth/data/models/auth_session_result_model.dart';
import 'package:ocupa2/features/auth/data/models/forgot_password_request_model.dart';
import 'package:ocupa2/features/auth/data/models/login_request_model.dart';
import 'package:ocupa2/features/auth/data/models/register_request_model.dart';
import 'package:ocupa2/features/auth/data/providers/auth_data_providers.dart';
import 'package:ocupa2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ocupa2/features/auth/domain/entities/auth_session_result.dart';
import 'package:ocupa2/features/auth/domain/repositories/auth_repository.dart';
import 'package:ocupa2/features/profile/data/models/profile_model.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';

void main() {
  group('Auth request models', () {
    test('serializa RegisterRequestModel', () {
      final request = RegisterRequestModel(
        email: 'persona@correo.com',
        firstName: 'Juan',
        lastName: 'Perez',
        password: 'string',
        referralMatricula: '99999999',
      );

      expect(request.toJson(), {
        'email': 'persona@correo.com',
        'firstName': 'Juan',
        'lastName': 'Perez',
        'password': 'string',
        'referralMatricula': '99999999',
      });
    });

    test('serializa LoginRequestModel', () {
      final request = LoginRequestModel(
        email: 'user@example.com',
        password: 'string',
      );

      expect(request.toJson(), {
        'email': 'user@example.com',
        'password': 'string',
      });
    });

    test('serializa ForgotPasswordRequestModel', () {
      final request = ForgotPasswordRequestModel(
        email: 'user@example.com',
        referralMatricula: '99999999',
      );

      expect(request.toJson(), {
        'email': 'user@example.com',
        'referralMatricula': '99999999',
      });
    });

    test('aplica trim a los campos permitidos', () {
      final register = RegisterRequestModel(
        email: ' persona@correo.com ',
        firstName: ' Juan ',
        lastName: ' Perez ',
        password: ' string ',
        referralMatricula: ' 99999999 ',
      );
      final login = LoginRequestModel(
        email: ' user@example.com ',
        password: ' string ',
      );
      final forgotPassword = ForgotPasswordRequestModel(
        email: ' user@example.com ',
        referralMatricula: ' 99999999 ',
      );

      expect(register.toJson()['email'], 'persona@correo.com');
      expect(register.toJson()['firstName'], 'Juan');
      expect(register.toJson()['lastName'], 'Perez');
      expect(register.toJson()['referralMatricula'], '99999999');
      expect(login.toJson()['email'], 'user@example.com');
      expect(forgotPassword.toJson()['email'], 'user@example.com');
      expect(forgotPassword.toJson()['referralMatricula'], '99999999');
    });

    test('la contrasena no se modifica', () {
      final register = RegisterRequestModel(
        email: 'persona@correo.com',
        firstName: 'Juan',
        lastName: 'Perez',
        password: ' string ',
        referralMatricula: '99999999',
      );
      final login = LoginRequestModel(
        email: 'user@example.com',
        password: ' string ',
      );

      expect(register.toJson()['password'], ' string ');
      expect(login.toJson()['password'], ' string ');
    });
  });

  group('AuthSessionResultModel', () {
    test('parsea respuesta completa', () {
      final result = AuthSessionResultModel.fromApiResponse(_authResponse());

      expect(result.token, 'token-value');
      expect(result.tokenType, 'Bearer');
      expect(result.user.id, 'user-1');
      expect(result.user.email, 'user@example.com');
    });

    test('reutiliza Profile y ProfileModel para user', () {
      final result = AuthSessionResultModel.fromApiResponse(_authResponse());

      expect(result.user, isA<Profile>());
      expect(result.user, isA<ProfileModel>());
    });

    test('soporta campos opcionales del usuario', () {
      final response = _authResponse(
        user: _userJson(
          firstName: null,
          lastName: null,
          nombre: null,
          cedula: null,
          gender: null,
          birthDate: null,
          referralMatricula: null,
          role: null,
          createdAt: null,
          lastLoginAt: null,
        ),
      );

      final result = AuthSessionResultModel.fromApiResponse(response);

      expect(result.user.firstName, isNull);
      expect(result.user.lastName, isNull);
      expect(result.user.cedula, isNull);
      expect(result.user.gender, isNull);
      expect(result.user.birthDate, isNull);
    });

    test('parsea profileCompleted true', () {
      final result = AuthSessionResultModel.fromApiResponse(
        _authResponse(user: _userJson(profileCompleted: true)),
      );

      expect(result.user.profileCompleted, isTrue);
    });

    test('parsea profileCompleted false', () {
      final result = AuthSessionResultModel.fromApiResponse(
        _authResponse(user: _userJson(profileCompleted: false)),
      );

      expect(result.user.profileCompleted, isFalse);
    });

    test('token vacio produce error controlado', () {
      expect(
        () =>
            AuthSessionResultModel.fromApiResponse(_authResponse(token: '   ')),
        throwsA(isA<ApiException>()),
      );
    });

    test('user invalido produce error controlado', () {
      expect(
        () => AuthSessionResultModel.fromApiResponse(
          _authResponse(user: 'invalid'),
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AuthRemoteDataSource', () {
    test('register usa POST /auth/register', () async {
      final client = _TestApiClient(_authResponse());
      final dataSource = AuthRemoteDataSourceImpl(client.apiClient);

      await dataSource.register(_registerRequest());

      expect(client.lastOptions.method, 'POST');
      expect(client.lastOptions.path, '/auth/register');
    });

    test('login usa POST /auth/login', () async {
      final client = _TestApiClient(_authResponse());
      final dataSource = AuthRemoteDataSourceImpl(client.apiClient);

      await dataSource.login(_loginRequest());

      expect(client.lastOptions.method, 'POST');
      expect(client.lastOptions.path, '/auth/login');
    });

    test('forgot password usa POST /auth/forgot-password', () async {
      final client = _TestApiClient({'ok': true});
      final dataSource = AuthRemoteDataSourceImpl(client.apiClient);

      await dataSource.forgotPassword(_forgotPasswordRequest());

      expect(client.lastOptions.method, 'POST');
      expect(client.lastOptions.path, '/auth/forgot-password');
    });

    test('los bodies enviados coinciden con el contrato', () async {
      final client = _TestApiClient(_authResponse());
      final dataSource = AuthRemoteDataSourceImpl(client.apiClient);

      await dataSource.register(_registerRequest());
      expect(client.lastOptions.data, _registerRequest().toJson());

      await dataSource.login(_loginRequest());
      expect(client.lastOptions.data, _loginRequest().toJson());

      await dataSource.forgotPassword(_forgotPasswordRequest());
      expect(client.lastOptions.data, _forgotPasswordRequest().toJson());
    });
  });

  group('AuthRepositoryImpl', () {
    test('register exitoso guarda el token', () async {
      final tokenStorage = _FakeTokenStorage();
      final repository = AuthRepositoryImpl(
        _FakeAuthRemoteDataSource(
          result: _sessionResult(token: 'register-token'),
        ),
        tokenStorage,
      );

      await repository.register(
        email: 'persona@correo.com',
        firstName: 'Juan',
        lastName: 'Perez',
        password: 'string',
        referralMatricula: '99999999',
      );

      expect(tokenStorage.savedTokens, ['register-token']);
    });

    test('login exitoso guarda el token', () async {
      final tokenStorage = _FakeTokenStorage();
      final repository = AuthRepositoryImpl(
        _FakeAuthRemoteDataSource(result: _sessionResult(token: 'login-token')),
        tokenStorage,
      );

      await repository.login(email: 'user@example.com', password: 'string');

      expect(tokenStorage.savedTokens, ['login-token']);
    });

    test('register fallido no guarda token', () async {
      final tokenStorage = _FakeTokenStorage();
      final repository = AuthRepositoryImpl(
        _FakeAuthRemoteDataSource(
          error: const ApiException(message: 'Correo ya registrado'),
        ),
        tokenStorage,
      );

      expect(
        () => repository.register(
          email: 'persona@correo.com',
          firstName: 'Juan',
          lastName: 'Perez',
          password: 'string',
          referralMatricula: '99999999',
        ),
        throwsA(isA<ApiException>()),
      );
      expect(tokenStorage.savedTokens, isEmpty);
    });

    test('login fallido no guarda token', () async {
      final tokenStorage = _FakeTokenStorage();
      final repository = AuthRepositoryImpl(
        _FakeAuthRemoteDataSource(
          error: const ApiException(message: 'Correo o clave incorrectos'),
        ),
        tokenStorage,
      );

      expect(
        () => repository.login(email: 'user@example.com', password: 'string'),
        throwsA(isA<ApiException>()),
      );
      expect(tokenStorage.savedTokens, isEmpty);
    });

    test('forgot password no modifica el token', () async {
      final tokenStorage = _FakeTokenStorage();
      final repository = AuthRepositoryImpl(
        _FakeAuthRemoteDataSource(result: _sessionResult()),
        tokenStorage,
      );

      await repository.forgotPassword(
        email: 'user@example.com',
        referralMatricula: '99999999',
      );

      expect(tokenStorage.savedTokens, isEmpty);
    });
  });

  group('Auth providers', () {
    test('el repository puede sustituirse con provider override', () {
      final fakeRepository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      expect(container.read(authRepositoryProvider), same(fakeRepository));
    });
  });
}

RegisterRequestModel _registerRequest() {
  return const RegisterRequestModel(
    email: 'persona@correo.com',
    firstName: 'Juan',
    lastName: 'Perez',
    password: 'string',
    referralMatricula: '99999999',
  );
}

LoginRequestModel _loginRequest() {
  return const LoginRequestModel(email: 'user@example.com', password: 'string');
}

ForgotPasswordRequestModel _forgotPasswordRequest() {
  return const ForgotPasswordRequestModel(
    email: 'user@example.com',
    referralMatricula: '99999999',
  );
}

Map<String, Object?> _authResponse({
  String token = 'token-value',
  Object? user,
}) {
  return {
    'ok': true,
    'data': {
      'token': token,
      'tokenType': 'Bearer',
      'user': user ?? _userJson(),
    },
  };
}

Map<String, Object?> _userJson({
  String id = 'user-1',
  String email = 'user@example.com',
  Object? firstName = 'Juan',
  Object? lastName = 'Perez',
  Object? nombre = 'Juan Perez',
  Object? cedula = '00112345678',
  Object? gender = 'masculino',
  Object? birthDate = '2026-08-03T12:39:09.852Z',
  bool profileCompleted = true,
  Object? referralMatricula = '99999999',
  Object? role = 'worker',
  Object? createdAt = '2026-08-03T12:39:09.852Z',
  Object? lastLoginAt = '2026-08-03T12:39:09.852Z',
}) {
  return {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'nombre': nombre,
    'cedula': cedula,
    'gender': gender,
    'birthDate': birthDate,
    'profileCompleted': profileCompleted,
    'referralMatricula': referralMatricula,
    'role': role,
    'createdAt': createdAt,
    'lastLoginAt': lastLoginAt,
  };
}

AuthSessionResult _sessionResult({String token = 'token-value'}) {
  return AuthSessionResult(
    token: token,
    tokenType: 'Bearer',
    user: Profile(
      id: 'user-1',
      email: 'user@example.com',
      profileCompleted: true,
    ),
  );
}

class _TestApiClient {
  _TestApiClient(this.responseData) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastOptions = options;
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: responseData,
            ),
          );
        },
      ),
    );
  }

  final Object? responseData;
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  late RequestOptions lastOptions;

  ApiClient get apiClient => ApiClient(dio);
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({this.result, this.error});

  final AuthSessionResult? result;
  final Object? error;

  @override
  Future<AuthSessionResult> register(RegisterRequestModel request) async {
    if (error != null) {
      throw error!;
    }

    return result ?? _sessionResult();
  }

  @override
  Future<AuthSessionResult> login(LoginRequestModel request) async {
    if (error != null) {
      throw error!;
    }

    return result ?? _sessionResult();
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestModel request) async {}
}

class _FakeTokenStorage implements TokenStorage {
  final savedTokens = <String>[];

  @override
  Future<void> saveAccessToken(String token) async {
    savedTokens.add(token);
  }

  @override
  Future<String?> readAccessToken() async {
    if (savedTokens.isEmpty) {
      return null;
    }

    return savedTokens.last;
  }

  @override
  Future<bool> hasAccessToken() async => savedTokens.isNotEmpty;

  @override
  Future<void> deleteAccessToken() async {
    savedTokens.clear();
  }

  @override
  Future<void> clearSession() async {
    savedTokens.clear();
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    return _sessionResult();
  }

  @override
  Future<AuthSessionResult> login({
    required String email,
    required String password,
  }) async {
    return _sessionResult();
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {}
}
