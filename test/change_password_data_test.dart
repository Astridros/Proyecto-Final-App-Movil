import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/features/change_password/data/datasources/change_password_remote_datasource.dart';
import 'package:ocupa2/features/change_password/data/models/change_password_request_model.dart';
import 'package:ocupa2/features/change_password/data/providers/change_password_data_providers.dart';
import 'package:ocupa2/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:ocupa2/features/change_password/domain/repositories/change_password_repository.dart';

void main() {
  group('ChangePasswordRequestModel', () {
    test('serialización correcta del request', () {
      const request = ChangePasswordRequestModel(password: 'NuevaClave123');

      expect(request.toJson(), {'password': 'NuevaClave123'});
    });

    test('la contraseña no se modifica', () {
      const request = ChangePasswordRequestModel(password: '  NuevaClave123  ');

      expect(request.toJson(), {'password': '  NuevaClave123  '});
    });
  });

  group('ChangePasswordRemoteDataSource', () {
    test('usa PUT /me/password', () async {
      final client = _TestApiClient(_successResponse());
      final dataSource = ChangePasswordRemoteDataSourceImpl(client.apiClient);

      await dataSource.changePassword(
        const ChangePasswordRequestModel(password: 'NuevaClave123'),
      );

      expect(client.lastOptions.method, 'PUT');
      expect(client.lastOptions.path, '/me/password');
    });

    test('el body enviado es correcto', () async {
      final client = _TestApiClient(_successResponse());
      final dataSource = ChangePasswordRemoteDataSourceImpl(client.apiClient);
      const request = ChangePasswordRequestModel(password: '  NuevaClave123  ');

      await dataSource.changePassword(request);

      expect(client.lastOptions.data, {'password': '  NuevaClave123  '});
    });

    test('respuesta exitosa completa normalmente', () async {
      final client = _TestApiClient(_successResponse());
      final dataSource = ChangePasswordRemoteDataSourceImpl(client.apiClient);

      await expectLater(
        dataSource.changePassword(
          const ChangePasswordRequestModel(password: 'NuevaClave123'),
        ),
        completes,
      );
    });

    test('respuesta con ok false produce error controlado', () async {
      final client = _TestApiClient({
        'ok': false,
        'data': {'message': 'No fue posible actualizar la clave.'},
      });
      final dataSource = ChangePasswordRemoteDataSourceImpl(client.apiClient);

      expect(
        () => dataSource.changePassword(
          const ChangePasswordRequestModel(password: 'NuevaClave123'),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'No fue posible actualizar la clave.',
          ),
        ),
      );
    });

    test('respuesta inválida produce error claro', () async {
      final client = _TestApiClient('Clave actualizada.');
      final dataSource = ChangePasswordRemoteDataSourceImpl(client.apiClient);

      expect(
        () => dataSource.changePassword(
          const ChangePasswordRequestModel(password: 'NuevaClave123'),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Respuesta inválida al cambiar la contraseña.',
          ),
        ),
      );
    });
  });

  group('ChangePasswordRepository', () {
    test('repository delega correctamente', () async {
      final dataSource = _FakeChangePasswordRemoteDataSource();
      final repository = ChangePasswordRepositoryImpl(dataSource);

      await repository.changePassword(password: 'NuevaClave123');

      expect(dataSource.changePasswordCalls, 1);
      expect(dataSource.lastRequest?.password, 'NuevaClave123');
    });

    test('error del datasource se propaga', () async {
      final dataSource = _FakeChangePasswordRemoteDataSource()
        ..error = const ApiException(message: 'No autorizado');
      final repository = ChangePasswordRepositoryImpl(dataSource);

      expect(
        () => repository.changePassword(password: 'NuevaClave123'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'No autorizado',
          ),
        ),
      );
    });
  });

  group('ChangePassword providers', () {
    test('provider puede sustituirse mediante override', () {
      final fakeRepository = _FakeChangePasswordRepository();
      final container = ProviderContainer(
        overrides: [
          changePasswordRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(changePasswordRepositoryProvider),
        same(fakeRepository),
      );
    });
  });
}

Map<String, Object?> _successResponse() {
  return {
    'ok': true,
    'data': {'message': 'Clave actualizada.'},
  };
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

class _FakeChangePasswordRemoteDataSource
    implements ChangePasswordRemoteDataSource {
  int changePasswordCalls = 0;
  ChangePasswordRequestModel? lastRequest;
  Object? error;

  @override
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    changePasswordCalls++;
    lastRequest = request;
    if (error != null) {
      throw error!;
    }
  }
}

class _FakeChangePasswordRepository implements ChangePasswordRepository {
  @override
  Future<void> changePassword({required String password}) async {}
}
