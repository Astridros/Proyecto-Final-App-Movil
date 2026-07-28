import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/features/offers/data/datasources/offers_remote_datasource.dart';
import 'package:ocupa2/features/offers/data/models/api_list_response.dart';
import 'package:ocupa2/features/offers/data/models/job_type_model.dart';
import 'package:ocupa2/features/offers/data/models/offer_model.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';

void main() {
  group('JobTypeModel', () {
    test('parsea un tipo con customFields y options', () {
      final jobType = JobTypeModel.fromJson(_jobTypeJson());

      expect(jobType.id, '6a445b6ca7eceacf02e1a107');
      expect(jobType.key, 'chofer');
      expect(jobType.name, 'Chofer');
      expect(jobType.active, isTrue);
      expect(jobType.customFields, hasLength(1));
      expect(jobType.customFields.first.options, [
        '01',
        '02',
        '03',
        '04',
        '05',
      ]);
    });

    test('parsea un tipo con customFields vacío', () {
      final jobType = JobTypeModel.fromJson(_jobTypeJson(customFields: []));

      expect(jobType.customFields, isEmpty);
    });

    test('acepta updatedAt ausente', () {
      final json = _jobTypeJson()..remove('updatedAt');

      final jobType = JobTypeModel.fromJson(json);

      expect(jobType.updatedAt, isNull);
    });

    test('parsea campo custom tipo check sin options', () {
      final jobType = JobTypeModel.fromJson(
        _jobTypeJson(
          customFields: [
            {
              'key': 'certificado',
              'label': 'Tiene certificado',
              'type': 'check',
              'required': false,
            },
          ],
        ),
      );

      expect(jobType.customFields.first.type, 'check');
      expect(jobType.customFields.first.options, isEmpty);
    });

    test('respuesta con lista vacía', () {
      final response = ApiListResponse<JobType>.fromJson({
        'ok': true,
        'data': [],
      }, JobTypeModel.fromJson);

      expect(response.data, isEmpty);
    });

    test('se pueden filtrar tipos activos sin perder el modelo completo', () {
      final response = ApiListResponse<JobType>.fromJson({
        'ok': true,
        'data': [
          _jobTypeJson(active: true),
          _jobTypeJson(id: 'inactive-id', key: 'inactivo', active: false),
        ],
      }, JobTypeModel.fromJson);

      final activeTypes = response.data.where((item) => item.active).toList();

      expect(response.data, hasLength(2));
      expect(activeTypes, hasLength(1));
      expect(activeTypes.single.key, 'chofer');
    });
  });

  group('OfferModel', () {
    test('parsea una oferta completa', () {
      final offer = OfferModel.fromJson(_offerJson());

      expect(offer.id, '6a4ef553021413b716070dc8');
      expect(offer.jobTypeKey, 'chofer');
      expect(offer.jobTypeName, 'Chofer');
      expect(offer.contractType, 'temporal');
      expect(offer.location.lat, 18.4861);
      expect(offer.payment.amount, 35000);
      expect(offer.questions, hasLength(1));
      expect(offer.isIdentityRevealed, isFalse);
      expect(offer.likedByMe, isFalse);
    });

    test('acepta deadline null', () {
      final offer = OfferModel.fromJson(_offerJson(deadline: null));

      expect(offer.deadline, isNull);
    });

    test('parsea customAnswers como objeto', () {
      final offer = OfferModel.fromJson(
        _offerJson(customAnswers: {'categoria_licencia': '03'}),
      );

      expect(offer.customAnswers['categoria_licencia'], '03');
    });

    test('parsea customAnswers como lista vacía', () {
      final offer = OfferModel.fromJson(_offerJson(customAnswers: []));

      expect(offer.customAnswers, isEmpty);
    });

    test('acepta questions vacías', () {
      final offer = OfferModel.fromJson(_offerJson(questions: []));

      expect(offer.questions, isEmpty);
    });

    test('parsea amount entero', () {
      final offer = OfferModel.fromJson(
        _offerJson(
          payment: {'amount': 35000, 'currency': 'DOP', 'period': 'total'},
        ),
      );

      expect(offer.payment.amount, 35000.0);
    });

    test('parsea amount decimal', () {
      final offer = OfferModel.fromJson(
        _offerJson(
          payment: {'amount': 1250.75, 'currency': 'DOP', 'period': 'hora'},
        ),
      );

      expect(offer.payment.amount, 1250.75);
    });

    test('parsea lat/lng enteros y decimales', () {
      final integerLocation = OfferModel.fromJson(
        _offerJson(location: {'lat': 0, 'lng': 0}),
      );
      final decimalLocation = OfferModel.fromJson(
        _offerJson(location: {'lat': 18.4861, 'lng': -69.9312}),
      );

      expect(integerLocation.location.lat, 0.0);
      expect(integerLocation.location.lng, 0.0);
      expect(decimalLocation.location.lat, 18.4861);
      expect(decimalLocation.location.lng, -69.9312);
    });

    test('photo con valor inválido no rompe el parseo', () {
      final offer = OfferModel.fromJson(_offerJson(photo: 'string'));

      expect(offer.photo, 'string');
    });

    test('lista de ofertas vacía', () {
      final response = ApiListResponse<Offer>.fromJson({
        'ok': true,
        'data': [],
      }, OfferModel.fromJson);

      expect(response.data, isEmpty);
    });

    test('respuesta con data que no es lista produce error claro', () {
      expect(
        () => ApiListResponse<Offer>.fromJson({
          'ok': true,
          'data': {},
        }, OfferModel.fromJson),
        throwsA(isA<ApiException>()),
      );
    });

    test('falta de campo esencial produce error claro', () {
      final json = _offerJson()..remove('jobTypeKey');

      expect(() => OfferModel.fromJson(json), throwsA(isA<ApiException>()));
    });
  });

  group('OffersRemoteDataSource', () {
    test('query sin filtros no envía parámetros vacíos', () async {
      final client = _TestApiClient({'ok': true, 'data': []});
      final dataSource = OffersRemoteDataSourceImpl(client.apiClient);

      await dataSource.getOffers();

      expect(client.lastOptions.queryParameters, isEmpty);
    });

    test('query con jobTypeKey envía el valor correcto', () async {
      final client = _TestApiClient({'ok': true, 'data': []});
      final dataSource = OffersRemoteDataSourceImpl(client.apiClient);

      await dataSource.getOffers(jobTypeKey: ' chofer ');

      expect(client.lastOptions.queryParameters, {'jobTypeKey': 'chofer'});
    });

    test('query con contractType envía el valor correcto', () async {
      final client = _TestApiClient({'ok': true, 'data': []});
      final dataSource = OffersRemoteDataSourceImpl(client.apiClient);

      await dataSource.getOffers(contractType: 'temporal');

      expect(client.lastOptions.queryParameters, {'contractType': 'temporal'});
    });

    test('query con ambos filtros envía ambos valores', () async {
      final client = _TestApiClient({'ok': true, 'data': []});
      final dataSource = OffersRemoteDataSourceImpl(client.apiClient);

      await dataSource.getOffers(
        jobTypeKey: 'chofer',
        contractType: 'temporal',
      );

      expect(client.lastOptions.queryParameters, {
        'jobTypeKey': 'chofer',
        'contractType': 'temporal',
      });
    });
  });

  group('Offers providers', () {
    test('el repositorio puede sustituirse mediante override', () {
      final fakeRepository = _FakeOffersRepository();
      final container = ProviderContainer(
        overrides: [offersRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      expect(container.read(offersRepositoryProvider), same(fakeRepository));
    });
  });
}

Map<String, Object?> _jobTypeJson({
  String id = '6a445b6ca7eceacf02e1a107',
  String key = 'chofer',
  bool active = true,
  Object? customFields,
}) {
  return {
    'id': id,
    'key': key,
    'active': active,
    'createdAt': '2026-07-01T00:12:28+00:00',
    'updatedAt': '2026-07-07T23:12:58+00:00',
    'customFields':
        customFields ??
        [
          {
            'key': 'categoria_licencia',
            'label': 'Categoría de licencia',
            'type': 'select',
            'required': true,
            'options': ['01', '02', '03', '04', '05'],
          },
        ],
    'name': 'Chofer',
  };
}

Map<String, Object?> _offerJson({
  Object? deadline = '2026-08-30T00:00:00+00:00',
  Object? customAnswers,
  Object? questions,
  Object? payment,
  Object? location,
  String photo = 'https://ocupa2.ia3x.com/media/imagen.png',
}) {
  return {
    'id': '6a4ef553021413b716070dc8',
    'jobTypeKey': 'chofer',
    'jobTypeName': 'Chofer',
    'contractType': 'temporal',
    'description': 'Se necesita chofer...',
    'address': 'Santo Domingo, República Dominicana',
    'location': location ?? {'lat': 18.4861, 'lng': -69.9312},
    'payment':
        payment ?? {'amount': 35000, 'currency': 'DOP', 'period': 'total'},
    'photo': photo,
    'deadline': deadline,
    'customAnswers': customAnswers ?? {'categoria_licencia': '03'},
    'questions':
        questions ??
        [
          {
            'id': 'q1',
            'label': '¿Posee licencia categoría 03 vigente?',
            'type': 'text',
            'required': true,
          },
        ],
    'status': 'published',
    'applicantsCount': 1,
    'likesCount': 0,
    'createdAt': '2026-07-09T01:11:47+00:00',
    'updatedAt': '2026-07-09T01:11:47+00:00',
    'isIdentityRevealed': false,
    'likedByMe': false,
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

class _FakeOffersRepository implements OffersRepository {
  @override
  Future<List<JobType>> getJobTypes() async {
    return const [];
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    return const [];
  }
}
