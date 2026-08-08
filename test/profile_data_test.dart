import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:ocupa2/features/profile/data/models/profile_model.dart';
import 'package:ocupa2/features/profile/data/models/update_profile_request_model.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  group('ProfileModel', () {
    test('parsea GET /me', () {
      final profile = ProfileModel.fromApiResponse({
        'ok': true,
        'data': _profileJson(),
      });

      expect(profile.id, 'user-1');
      expect(profile.email, 'astrid@example.com');
      expect(profile.firstName, 'Astrid');
      expect(profile.lastName, 'Diaz');
      expect(profile.nombre, 'Astrid Diaz');
      expect(profile.referralMatricula, 'MAT-001');
      expect(profile.role, 'worker');
      expect(profile.cedula, '00112345678');
      expect(profile.gender, 'female');
    });

    test('parsea PUT /me/profile', () {
      final profile = ProfileModel.fromApiResponse({
        'ok': true,
        'data': _profileJson(
          firstName: 'Ana',
          lastName: 'Perez',
          cedula: '40212345678',
          gender: 'female',
        ),
      });

      expect(profile.firstName, 'Ana');
      expect(profile.lastName, 'Perez');
      expect(profile.cedula, '40212345678');
      expect(profile.gender, 'female');
    });

    test('convierte fechas ISO8601', () {
      final profile = ProfileModel.fromJson(_profileJson());

      expect(profile.createdAt, DateTime.parse('2026-07-01T10:20:30Z'));
      expect(profile.updatedAt, DateTime.parse('2026-07-02T10:20:30Z'));
      expect(profile.lastLoginAt, DateTime.parse('2026-07-03T10:20:30Z'));
      expect(profile.birthDate, DateTime.parse('1997-05-12T00:00:00Z'));
    });

    test('soporta campos opcionales null', () {
      final profile = ProfileModel.fromJson(
        _profileJson(
          firstName: null,
          lastName: null,
          nombre: null,
          referralMatricula: null,
          role: null,
          createdAt: null,
          updatedAt: null,
          lastLoginAt: null,
          birthDate: null,
          cedula: null,
          gender: null,
        ),
      );

      expect(profile.firstName, isNull);
      expect(profile.lastName, isNull);
      expect(profile.nombre, isNull);
      expect(profile.referralMatricula, isNull);
      expect(profile.role, isNull);
      expect(profile.createdAt, isNull);
      expect(profile.updatedAt, isNull);
      expect(profile.lastLoginAt, isNull);
      expect(profile.birthDate, isNull);
      expect(profile.cedula, isNull);
      expect(profile.gender, isNull);
    });

    test('parsea profileCompleted false', () {
      final profile = ProfileModel.fromJson(
        _profileJson(profileCompleted: false),
      );

      expect(profile.profileCompleted, isFalse);
    });

    test('parsea profileCompleted true', () {
      final profile = ProfileModel.fromJson(
        _profileJson(profileCompleted: true),
      );

      expect(profile.profileCompleted, isTrue);
    });
  });

  group('UpdateProfileRequestModel', () {
    test('serializa los campos esperados', () {
      final request = UpdateProfileRequestModel(
        firstName: 'Astrid',
        lastName: 'Diaz',
        cedula: '00112345678',
        gender: 'female',
        birthDate: DateTime.utc(1997, 5, 12),
        email: 'astrid@example.com',
        referralMatricula: '12345678',
      );

      expect(request.toJson(), {
        'firstName': 'Astrid',
        'lastName': 'Diaz',
        'cedula': '00112345678',
        'gender': 'female',
        'birthDate': '1997-05-12T00:00:00.000Z',
        'email': 'astrid@example.com',
        'referralMatricula': '12345678',
      });
    });
  });

  group('ProfileRemoteDataSource', () {
    test('GET /me llama el endpoint correcto y parsea respuesta', () async {
      final client = _TestApiClient({'ok': true, 'data': _profileJson()});
      final dataSource = ProfileRemoteDataSourceImpl(client.apiClient);

      final profile = await dataSource.getProfile();

      expect(client.lastOptions.method, 'GET');
      expect(client.lastOptions.path, '/me');
      expect(profile.email, 'astrid@example.com');
    });

    test('PUT /me/profile llama el endpoint correcto con body', () async {
      final client = _TestApiClient({'ok': true, 'data': _profileJson()});
      final dataSource = ProfileRemoteDataSourceImpl(client.apiClient);
      final request = UpdateProfileRequestModel(
        firstName: 'Astrid',
        lastName: 'Diaz',
        cedula: '00112345678',
        gender: 'female',
        birthDate: DateTime.utc(1997, 5, 12),
        email: 'astrid@example.com',
        referralMatricula: '12345678',
      );

      final profile = await dataSource.updateProfile(request);

      expect(client.lastOptions.method, 'PUT');
      expect(client.lastOptions.path, '/me/profile');
      expect(client.lastOptions.data, request.toJson());
      expect(profile.id, 'user-1');
    });
  });

  group('ProfileRepository', () {
    test('getProfile delega al datasource', () async {
      final dataSource = _FakeProfileRemoteDataSource();
      final repository = ProfileRepositoryImpl(dataSource);

      final profile = await repository.getProfile();

      expect(dataSource.getProfileCalls, 1);
      expect(profile, same(dataSource.profile));
    });

    test('updateProfile delega al datasource con request model', () async {
      final dataSource = _FakeProfileRemoteDataSource();
      final repository = ProfileRepositoryImpl(dataSource);
      final birthDate = DateTime.utc(1997, 5, 12);

      await repository.updateProfile(
        firstName: 'Astrid',
        lastName: 'Diaz',
        cedula: '00112345678',
        gender: 'female',
        birthDate: birthDate,
        email: 'astrid@example.com',
        referralMatricula: '12345678',
      );

      expect(dataSource.updateProfileCalls, 1);
      expect(dataSource.lastRequest?.firstName, 'Astrid');
      expect(dataSource.lastRequest?.lastName, 'Diaz');
      expect(dataSource.lastRequest?.cedula, '00112345678');
      expect(dataSource.lastRequest?.gender, 'female');
      expect(dataSource.lastRequest?.birthDate, birthDate);
      expect(dataSource.lastRequest?.email, 'astrid@example.com');
      expect(dataSource.lastRequest?.referralMatricula, '12345678');
    });
  });

  group('Profile providers', () {
    test('el repositorio puede sustituirse mediante override', () {
      final fakeRepository = _FakeProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(profileRepositoryProvider), same(fakeRepository));
    });
  });
}

Map<String, Object?> _profileJson({
  String id = 'user-1',
  String email = 'astrid@example.com',
  Object? firstName = 'Astrid',
  Object? lastName = 'Diaz',
  Object? nombre = 'Astrid Diaz',
  Object? referralMatricula = 'MAT-001',
  Object? role = 'worker',
  Object? createdAt = '2026-07-01T10:20:30Z',
  Object? updatedAt = '2026-07-02T10:20:30Z',
  Object? lastLoginAt = '2026-07-03T10:20:30Z',
  Object? birthDate = '1997-05-12T00:00:00Z',
  Object? cedula = '00112345678',
  Object? gender = 'female',
  bool profileCompleted = false,
}) {
  return {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'nombre': nombre,
    'referralMatricula': referralMatricula,
    'role': role,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'lastLoginAt': lastLoginAt,
    'birthDate': birthDate,
    'cedula': cedula,
    'gender': gender,
    'profileCompleted': profileCompleted,
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

class _FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  final profile = ProfileModel.fromJson(_profileJson());
  int getProfileCalls = 0;
  int updateProfileCalls = 0;
  UpdateProfileRequestModel? lastRequest;

  @override
  Future<Profile> getProfile() async {
    getProfileCalls++;
    return profile;
  }

  @override
  Future<Profile> updateProfile(UpdateProfileRequestModel request) async {
    updateProfileCalls++;
    lastRequest = request;
    return profile;
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Profile> getProfile() async {
    return ProfileModel.fromJson(_profileJson());
  }

  @override
  Future<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
    String? email,
    String? referralMatricula,
  }) async {
    return ProfileModel.fromJson(_profileJson());
  }
}
