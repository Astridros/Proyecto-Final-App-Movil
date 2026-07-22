import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocupa2/core/config/environment.dart';
import 'package:ocupa2/core/constants/api_constants.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/conflict_exception.dart';
import 'package:ocupa2/core/errors/error_mapper.dart';
import 'package:ocupa2/core/errors/forbidden_exception.dart';
import 'package:ocupa2/core/errors/network_exception.dart';
import 'package:ocupa2/core/errors/not_found_exception.dart';
import 'package:ocupa2/core/errors/server_exception.dart';
import 'package:ocupa2/core/errors/timeout_exception.dart';
import 'package:ocupa2/core/errors/unauthorized_exception.dart';
import 'package:ocupa2/core/errors/unknown_exception.dart';
import 'package:ocupa2/core/errors/validation_exception.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/core/network/auth_interceptor.dart';
import 'package:ocupa2/core/network/dio_provider.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('guarda token', () async {
      final storage = SecureTokenStorage(const FlutterSecureStorage());

      await storage.saveAccessToken('abc-token');

      expect(await storage.readAccessToken(), 'abc-token');
    });

    test('lee token', () async {
      FlutterSecureStorage.setMockInitialValues({
        'ocupa2.access_token': 'stored-token',
      });
      final storage = SecureTokenStorage(const FlutterSecureStorage());

      expect(await storage.readAccessToken(), 'stored-token');
    });

    test('confirma existencia de token', () async {
      final storage = SecureTokenStorage(const FlutterSecureStorage());

      await storage.saveAccessToken('abc-token');

      expect(await storage.hasAccessToken(), isTrue);
    });

    test('elimina token', () async {
      final storage = SecureTokenStorage(const FlutterSecureStorage());
      await storage.saveAccessToken('abc-token');

      await storage.deleteAccessToken();

      expect(await storage.readAccessToken(), isNull);
    });

    test('maneja token vacío de forma coherente', () async {
      final storage = SecureTokenStorage(const FlutterSecureStorage());

      await storage.saveAccessToken('   ');

      expect(await storage.readAccessToken(), isNull);
      expect(await storage.hasAccessToken(), isFalse);
    });
  });

  group('AuthInterceptor', () {
    test('agrega Bearer token cuando existe', () async {
      final options = await _captureRequestOptions(token: 'abc-token');

      expect(
        options.headers[ApiConstants.authorizationHeader],
        'Bearer abc-token',
      );
    });

    test('no agrega Authorization cuando no existe token', () async {
      final options = await _captureRequestOptions();

      expect(
        options.headers.containsKey(ApiConstants.authorizationHeader),
        isFalse,
      );
    });

    test('no sobrescribe Authorization explícito', () async {
      final options = await _captureRequestOptions(
        token: 'abc-token',
        headers: {ApiConstants.authorizationHeader: 'Custom value'},
      );

      expect(options.headers[ApiConstants.authorizationHeader], 'Custom value');
    });

    test('no agrega Bearer con token vacío', () async {
      final options = await _captureRequestOptions(token: '   ');

      expect(
        options.headers.containsKey(ApiConstants.authorizationHeader),
        isFalse,
      );
    });
  });

  group('ErrorMapper', () {
    test('connection timeout produce TimeoutException', () {
      final exception = _dioException(DioExceptionType.connectionTimeout);

      expect(ErrorMapper.fromDioException(exception), isA<TimeoutException>());
    });

    test('receive timeout produce TimeoutException', () {
      final exception = _dioException(DioExceptionType.receiveTimeout);

      expect(ErrorMapper.fromDioException(exception), isA<TimeoutException>());
    });

    test('connection error produce NetworkException', () {
      final exception = _dioException(DioExceptionType.connectionError);

      expect(ErrorMapper.fromDioException(exception), isA<NetworkException>());
    });

    test('400 produce ApiException', () {
      final mapped = ErrorMapper.fromDioException(_badResponse(400));

      expect(mapped, isA<ApiException>());
      expect(mapped.statusCode, 400);
    });

    test('401 produce UnauthorizedException', () {
      expect(
        ErrorMapper.fromDioException(_badResponse(401)),
        isA<UnauthorizedException>(),
      );
    });

    test('403 produce ForbiddenException', () {
      expect(
        ErrorMapper.fromDioException(_badResponse(403)),
        isA<ForbiddenException>(),
      );
    });

    test('404 produce NotFoundException', () {
      expect(
        ErrorMapper.fromDioException(_badResponse(404)),
        isA<NotFoundException>(),
      );
    });

    test('409 produce ConflictException', () {
      expect(
        ErrorMapper.fromDioException(_badResponse(409)),
        isA<ConflictException>(),
      );
    });

    test('422 produce ValidationException', () {
      expect(
        ErrorMapper.fromDioException(_badResponse(422)),
        isA<ValidationException>(),
      );
    });

    test('500 produce ServerException', () {
      expect(
        ErrorMapper.fromDioException(_badResponse(500)),
        isA<ServerException>(),
      );
    });

    test('error desconocido produce UnknownException', () {
      final exception = _dioException(DioExceptionType.unknown);

      expect(ErrorMapper.fromDioException(exception), isA<UnknownException>());
    });

    test('extrae message del backend cuando existe', () {
      final mapped = ErrorMapper.fromDioException(
        _badResponse(400, data: {'message': 'Mensaje útil'}),
      );

      expect(mapped.message, 'Mensaje útil');
    });

    test('no falla cuando response.data es String o null', () {
      final stringData = ErrorMapper.fromDioException(
        _badResponse(400, data: 'Mensaje como texto'),
      );
      final nullData = ErrorMapper.fromDioException(_badResponse(400));

      expect(stringData.message, 'Mensaje como texto');
      expect(nullData.message, 'La solicitud contiene datos inválidos.');
    });
  });

  group('ApiClient y providers', () {
    test('usa la base URL centralizada', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(dioProvider).options.baseUrl, Environment.baseUrl);
    });

    test('tiene los headers JSON esperados', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final headers = container.read(dioProvider).options.headers;

      expect(headers[ApiConstants.acceptHeader], ApiConstants.jsonContentType);
      expect(
        headers[ApiConstants.contentTypeHeader],
        ApiConstants.jsonContentType,
      );
    });

    test('los providers pueden sustituirse en pruebas', () {
      final fakeTokenStorage = _FakeTokenStorage('test-token');
      final fakeDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final fakeApiClient = ApiClient(fakeDio);
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeTokenStorage),
          dioProvider.overrideWithValue(fakeDio),
          apiClientProvider.overrideWithValue(fakeApiClient),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(tokenStorageProvider), same(fakeTokenStorage));
      expect(container.read(dioProvider), same(fakeDio));
      expect(container.read(apiClientProvider), same(fakeApiClient));
    });
  });
}

Future<RequestOptions> _captureRequestOptions({
  String? token,
  Map<String, dynamic>? headers,
}) async {
  late RequestOptions capturedOptions;
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(AuthInterceptor(_FakeTokenStorage(token)));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        capturedOptions = options;
        handler.resolve(
          Response<void>(requestOptions: options, statusCode: 200),
        );
      },
    ),
  );

  await dio.get<void>('/sample', options: Options(headers: headers));

  return capturedOptions;
}

DioException _dioException(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/sample'),
    type: type,
  );
}

DioException _badResponse(int statusCode, {Object? data}) {
  final requestOptions = RequestOptions(path: '/sample');

  return DioException(
    requestOptions: requestOptions,
    response: Response<Object?>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage([this._token]);

  String? _token;

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> readAccessToken() async {
    final normalizedToken = _token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return null;
    }

    return normalizedToken;
  }

  @override
  Future<bool> hasAccessToken() async {
    return (await readAccessToken()) != null;
  }

  @override
  Future<void> deleteAccessToken() async {
    _token = null;
  }

  @override
  Future<void> clearSession() async {
    _token = null;
  }
}
