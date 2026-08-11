import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/conflict_exception.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/features/offers/data/datasources/offers_remote_datasource.dart';
import 'package:ocupa2/features/offers/data/models/apply_offer_answer_model.dart';
import 'package:ocupa2/features/offers/data/models/apply_offer_request_model.dart';
import 'package:ocupa2/features/offers/data/models/apply_offer_result_model.dart';
import 'package:ocupa2/features/offers/data/models/api_list_response.dart';
import 'package:ocupa2/features/offers/data/models/job_type_model.dart';
import 'package:ocupa2/features/offers/data/models/offer_like_result_model.dart';
import 'package:ocupa2/features/offers/data/models/offer_model.dart';
import 'package:ocupa2/features/offers/data/models/offer_question_model.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/data/repositories/offers_repository_impl.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';

void main() {
  group('JobTypeModel', () {
    test('parsea un tipo con customFields y options', () {
      final jobType =
      JobTypeModel.fromJson(
        _jobTypeJson(),
      );

      expect(
        jobType.id,
        '6a445b6ca7eceacf02e1a107',
      );

      expect(
        jobType.key,
        'chofer',
      );

      expect(
        jobType.name,
        'Chofer',
      );

      expect(
        jobType.active,
        isTrue,
      );

      expect(
        jobType.customFields,
        hasLength(1),
      );

      expect(
        jobType.customFields.first.options,
        [
          '01',
          '02',
          '03',
          '04',
          '05',
        ],
      );
    });

    test('parsea un tipo con customFields vacío', () {
      final jobType =
      JobTypeModel.fromJson(
        _jobTypeJson(
          customFields: [],
        ),
      );

      expect(
        jobType.customFields,
        isEmpty,
      );
    });

    test('acepta updatedAt ausente', () {
      final json =
      _jobTypeJson()
        ..remove(
          'updatedAt',
        );

      final jobType =
      JobTypeModel.fromJson(
        json,
      );

      expect(
        jobType.updatedAt,
        isNull,
      );
    });

    test(
      'parsea campo custom tipo check sin options',
          () {
        final jobType =
        JobTypeModel.fromJson(
          _jobTypeJson(
            customFields: [
              {
                'key': 'certificado',
                'label':
                'Tiene certificado',
                'type': 'check',
                'required': false,
              },
            ],
          ),
        );

        expect(
          jobType.customFields.first.type,
          'check',
        );

        expect(
          jobType.customFields.first.options,
          isEmpty,
        );
      },
    );

    test('respuesta con lista vacía', () {
      final response =
      ApiListResponse<JobType>.fromJson(
        {
          'ok': true,
          'data': [],
        },
        JobTypeModel.fromJson,
      );

      expect(
        response.data,
        isEmpty,
      );
    });

    test(
      'se pueden filtrar tipos activos sin perder el modelo completo',
          () {
        final response =
        ApiListResponse<JobType>.fromJson(
          {
            'ok': true,
            'data': [
              _jobTypeJson(
                active: true,
              ),
              _jobTypeJson(
                id: 'inactive-id',
                key: 'inactivo',
                active: false,
              ),
            ],
          },
          JobTypeModel.fromJson,
        );

        final activeTypes =
        response.data
            .where(
              (item) =>
          item.active,
        )
            .toList();

        expect(
          response.data,
          hasLength(2),
        );

        expect(
          activeTypes,
          hasLength(1),
        );

        expect(
          activeTypes.single.key,
          'chofer',
        );
      },
    );
  });

  group('OfferModel', () {
    test('parsea una oferta completa', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(),
      );

      expect(
        offer.id,
        '6a4ef553021413b716070dc8',
      );

      expect(
        offer.jobTypeKey,
        'chofer',
      );

      expect(
        offer.jobTypeName,
        'Chofer',
      );

      expect(
        offer.contractType,
        'temporal',
      );

      expect(
        offer.location.lat,
        18.4861,
      );

      expect(
        offer.payment.amount,
        35000,
      );

      expect(
        offer.questions,
        hasLength(1),
      );

      expect(
        offer.isIdentityRevealed,
        isFalse,
      );

      expect(
        offer.likedByMe,
        isFalse,
      );
    });

    test('acepta deadline null', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          deadline: null,
        ),
      );

      expect(
        offer.deadline,
        isNull,
      );
    });

    test('parsea customAnswers como objeto', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          customAnswers: {
            'categoria_licencia':
            '03',
          },
        ),
      );

      expect(
        offer.customAnswers[
        'categoria_licencia'],
        '03',
      );
    });

    test('parsea customAnswers como lista vacía', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          customAnswers: [],
        ),
      );

      expect(
        offer.customAnswers,
        isEmpty,
      );
    });

    test('acepta questions vacías', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          questions: [],
        ),
      );

      expect(
        offer.questions,
        isEmpty,
      );
    });

    test('parsea amount entero', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          payment: {
            'amount': 35000,
            'currency': 'DOP',
            'period': 'total',
          },
        ),
      );

      expect(
        offer.payment.amount,
        35000.0,
      );
    });

    test('parsea amount decimal', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          payment: {
            'amount': 1250.75,
            'currency': 'DOP',
            'period': 'hora',
          },
        ),
      );

      expect(
        offer.payment.amount,
        1250.75,
      );
    });

    test('parsea lat/lng enteros y decimales', () {
      final integerLocation =
      OfferModel.fromJson(
        _offerJson(
          location: {
            'lat': 0,
            'lng': 0,
          },
        ),
      );

      final decimalLocation =
      OfferModel.fromJson(
        _offerJson(
          location: {
            'lat': 18.4861,
            'lng': -69.9312,
          },
        ),
      );

      expect(
        integerLocation.location.lat,
        0.0,
      );

      expect(
        integerLocation.location.lng,
        0.0,
      );

      expect(
        decimalLocation.location.lat,
        18.4861,
      );

      expect(
        decimalLocation.location.lng,
        -69.9312,
      );
    });

    test('photo con valor inválido no rompe el parseo', () {
      final offer =
      OfferModel.fromJson(
        _offerJson(
          photo: 'string',
        ),
      );

      expect(
        offer.photo,
        'string',
      );
    });

    test('lista de ofertas vacía', () {
      final response =
      ApiListResponse<Offer>.fromJson(
        {
          'ok': true,
          'data': [],
        },
        OfferModel.fromJson,
      );

      expect(
        response.data,
        isEmpty,
      );
    });

    test(
      'respuesta con data que no es lista produce error claro',
          () {
        expect(
              () =>
          ApiListResponse<Offer>.fromJson(
            {
              'ok': true,
              'data': {},
            },
            OfferModel.fromJson,
          ),
          throwsA(
            isA<ApiException>(),
          ),
        );
      },
    );

    test(
      'falta de campo esencial produce error claro',
          () {
        final json =
        _offerJson()
          ..remove(
            'jobTypeKey',
          );

        expect(
              () =>
              OfferModel.fromJson(
                json,
              ),
          throwsA(
            isA<ApiException>(),
          ),
        );
      },
    );
  });

  group('OfferQuestionModel', () {
    test('OfferQuestion sin options', () {
      final question =
      OfferQuestionModel.fromJson(
        {
          'id': 'q1',
          'label':
          '¿Tienes experiencia?',
          'type': 'text',
          'required': true,
        },
      );

      expect(
        question.options,
        isEmpty,
      );
    });

    test('OfferQuestion con options', () {
      final question =
      OfferQuestionModel.fromJson(
        {
          'id': 'q1',
          'label': 'Turno',
          'type': 'select',
          'required': true,
          'options': [
            'Mañana',
            'Tarde',
          ],
        },
      );

      expect(
        question.options,
        [
          'Mañana',
          'Tarde',
        ],
      );
    });

    test('ignora opciones no String', () {
      final question =
      OfferQuestionModel.fromJson(
        {
          'id': 'q1',
          'label': 'Turno',
          'type': 'select',
          'required': true,
          'options': [
            'Mañana',
            2,
            null,
            'Tarde',
          ],
        },
      );

      expect(
        question.options,
        [
          'Mañana',
          'Tarde',
        ],
      );
    });
  });

  group('ApplyOffer models', () {
    test('serialización de ApplyOfferAnswer', () {
      const answer =
      ApplyOfferAnswerModel(
        questionId: 'q1',
        value: 'Sí',
      );

      expect(
        answer.toJson(),
        {
          'questionId': 'q1',
          'value': 'Sí',
        },
      );
    });

    test('serialización exacta del request', () {
      const request =
      ApplyOfferRequestModel(
        comment: 'Ejemplo',
        answers: [
          ApplyOfferAnswer(
            questionId: 'q1',
            value: 'Respuesta',
          ),
        ],
      );

      expect(
        request.toJson(),
        {
          'comment': 'Ejemplo',
          'answers': [
            {
              'questionId': 'q1',
              'value': 'Respuesta',
            },
          ],
        },
      );
    });

    test('answers vacías', () {
      const request =
      ApplyOfferRequestModel(
        comment: 'Ejemplo',
        answers: [],
      );

      expect(
        request.toJson(),
        {
          'comment': 'Ejemplo',
          'answers': [],
        },
      );
    });

    test('parseo de resultado id/status', () {
      final result =
      ApplyOfferResultModel
          .fromApiResponse(
        {
          'ok': true,
          'data': {
            'id':
            'application-id',
            'status':
            'applied',
          },
        },
      );

      expect(
        result.id,
        'application-id',
      );

      expect(
        result.status,
        'applied',
      );
    });

    test('resultado sin id produce error', () {
      expect(
            () =>
            ApplyOfferResultModel
                .fromApiResponse(
              {
                'ok': true,
                'data': {
                  'status':
                  'applied',
                },
              },
            ),
        throwsA(
          isA<ApiException>(),
        ),
      );
    });
  });

  group('OfferLikeResultModel', () {
    test('parseo liked true', () {
      final result =
      OfferLikeResultModel
          .fromApiResponse(
        _likeResultJson(
          liked: true,
          likesCount: 2,
        ),
      );

      expect(
        result.liked,
        isTrue,
      );
    });

    test('parseo liked false', () {
      final result =
      OfferLikeResultModel
          .fromApiResponse(
        _likeResultJson(
          liked: false,
          likesCount: 2,
        ),
      );

      expect(
        result.liked,
        isFalse,
      );
    });

    test('parseo likesCount entero', () {
      final result =
      OfferLikeResultModel
          .fromApiResponse(
        _likeResultJson(
          likesCount: 3,
        ),
      );

      expect(
        result.likesCount,
        3,
      );
    });

    test(
      'parseo likesCount numerico convertido a int',
          () {
        final result =
        OfferLikeResultModel
            .fromApiResponse(
          _likeResultJson(
            likesCount: 3.8,
          ),
        );

        expect(
          result.likesCount,
          3,
        );
      },
    );

    test(
      'falta liked produce error controlado',
          () {
        expect(
              () =>
              OfferLikeResultModel
                  .fromApiResponse(
                {
                  'ok': true,
                  'data': {
                    'likesCount': 1,
                  },
                },
              ),
          throwsA(
            isA<ApiException>(),
          ),
        );
      },
    );

    test(
      'falta likesCount produce error controlado',
          () {
        expect(
              () =>
              OfferLikeResultModel
                  .fromApiResponse(
                {
                  'ok': true,
                  'data': {
                    'liked': true,
                  },
                },
              ),
          throwsA(
            isA<ApiException>(),
          ),
        );
      },
    );
  });

  group('OffersRemoteDataSource', () {
    test(
      'query sin filtros no envía parámetros vacíos',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.getOffers();

        expect(
          client.lastOptions
              .queryParameters,
          isEmpty,
        );
      },
    );

    test(
      'query con jobTypeKey envía el valor correcto',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.getOffers(
          jobTypeKey:
          ' chofer ',
        );

        expect(
          client.lastOptions
              .queryParameters,
          {
            'jobTypeKey':
            'chofer',
          },
        );
      },
    );

    test(
      'query con contractType envía el valor correcto',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.getOffers(
          contractType:
          'temporal',
        );

        expect(
          client.lastOptions
              .queryParameters,
          {
            'contractType':
            'temporal',
          },
        );
      },
    );

    test(
      'query con ambos filtros envía ambos valores',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.getOffers(
          jobTypeKey:
          'chofer',
          contractType:
          'temporal',
        );

        expect(
          client.lastOptions
              .queryParameters,
          {
            'jobTypeKey':
            'chofer',
            'contractType':
            'temporal',
          },
        );
      },
    );

    test('GET usa /offers/{id}', () async {
      final client =
      _TestApiClient(
        {
          'ok': true,
          'data':
          _offerJson(),
        },
      );

      final dataSource =
      OffersRemoteDataSourceImpl(
        client.apiClient,
      );

      await dataSource.getOfferById(
        ' offer-id ',
      );

      expect(
        client.lastOptions.method,
        'GET',
      );

      expect(
        client.lastOptions.path,
        '/offers/offer-id',
      );
    });

    test('GET parsea Offer existente', () async {
      final client =
      _TestApiClient(
        {
          'ok': true,
          'data':
          _offerJson(),
        },
      );

      final dataSource =
      OffersRemoteDataSourceImpl(
        client.apiClient,
      );

      final offer =
      await dataSource
          .getOfferById(
        'offer-id',
      );

      expect(
        offer,
        isA<Offer>(),
      );

      expect(
        offer.jobTypeName,
        'Chofer',
      );
    });

    test('ID vacío produce error claro', () {
      final client =
      _TestApiClient(
        {
          'ok': true,
          'data':
          _offerJson(),
        },
      );

      final dataSource =
      OffersRemoteDataSourceImpl(
        client.apiClient,
      );

      expect(
            () =>
            dataSource
                .getOfferById(
              '   ',
            ),
        throwsA(
          isA<ApiException>()
              .having(
                (error) =>
            error.message,
            'message',
            'El campo "id" es requerido.',
          ),
        ),
      );
    });

    test(
      'POST usa /offers/{id}/apply',
          () async {
        final client =
        _TestApiClient(
          _applyResultJson(),
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.applyToOffer(
          offerId:
          ' offer-id ',
          comment:
          'Ejemplo',
          answers:
          const [],
        );

        expect(
          client.lastOptions.method,
          'POST',
        );

        expect(
          client.lastOptions.path,
          '/offers/offer-id/apply',
        );
      },
    );

    test('POST envía body correcto', () async {
      final client =
      _TestApiClient(
        _applyResultJson(),
      );

      final dataSource =
      OffersRemoteDataSourceImpl(
        client.apiClient,
      );

      await dataSource.applyToOffer(
        offerId:
        'offer-id',
        comment:
        'Ejemplo',
        answers: const [
          ApplyOfferAnswer(
            questionId: 'q1',
            value: 'Respuesta',
          ),
        ],
      );

      expect(
        client.lastOptions.data,
        {
          'comment':
          'Ejemplo',
          'answers': [
            {
              'questionId':
              'q1',
              'value':
              'Respuesta',
            },
          ],
        },
      );
    });

    test(
      'Error 409 conserva “Ya aplicaste a esta oferta.”',
          () async {
        final client =
        _TestApiClient.conflict(
          {
            'ok': false,
            'error':
            'Ya aplicaste a esta oferta.',
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        expect(
              () =>
              dataSource
                  .applyToOffer(
                offerId:
                'offer-id',
                comment:
                'Ejemplo',
                answers:
                const [],
              ),
          throwsA(
            isA<ConflictException>()
                .having(
                  (error) =>
              error.message,
              'message',
              'Ya aplicaste a esta oferta.',
            ),
          ),
        );
      },
    );

    test(
      'POST usa /offers/{id}/like',
          () async {
        final client =
        _TestApiClient(
          _likeResultJson(),
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.likeOffer(
          ' offer-id ',
        );

        expect(
          client.lastOptions.method,
          'POST',
        );

        expect(
          client.lastOptions.path,
          '/offers/offer-id/like',
        );
      },
    );

    test(
      'DELETE usa /offers/{id}/like',
          () async {
        final client =
        _TestApiClient(
          _likeResultJson(
            liked: false,
          ),
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        await dataSource.unlikeOffer(
          ' offer-id ',
        );

        expect(
          client.lastOptions.method,
          'DELETE',
        );

        expect(
          client.lastOptions.path,
          '/offers/offer-id/like',
        );
      },
    );

    test('GET usa /me/likes', () async {
      final client =
      _TestApiClient(
        {
          'ok': true,
          'data': [
            _offerJson(),
          ],
        },
      );

      final dataSource =
      OffersRemoteDataSourceImpl(
        client.apiClient,
      );

      await dataSource
          .getMyLikedOffers();

      expect(
        client.lastOptions.method,
        'GET',
      );

      expect(
        client.lastOptions.path,
        '/me/likes',
      );
    });

    test('GET usa /me/offers', () async {
      final client =
      _TestApiClient(
        {
          'ok': true,
          'data': [
            _offerJson(),
          ],
        },
      );

      final dataSource =
      OffersRemoteDataSourceImpl(
        client.apiClient,
      );

      await dataSource.getMyOffers();

      expect(
        client.lastOptions.method,
        'GET',
      );

      expect(
        client.lastOptions.path,
        '/me/offers',
      );
    });

    test(
      'GET /me/offers reutiliza OfferModel',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [
              _offerJson(),
            ],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        final offers =
        await dataSource
            .getMyOffers();

        expect(
          offers,
          hasLength(1),
        );

        expect(
          offers.single,
          isA<Offer>(),
        );

        expect(
          offers.single.jobTypeName,
          'Chofer',
        );
      },
    );

    test(
      'lista de mis ofertas vacía funciona',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        final offers =
        await dataSource
            .getMyOffers();

        expect(
          offers,
          isEmpty,
        );
      },
    );

    test(
      'ID vacio produce error al dar like',
          () {
        final client =
        _TestApiClient(
          _likeResultJson(),
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        expect(
              () =>
              dataSource.likeOffer(
                ' ',
              ),
          throwsA(
            isA<ApiException>(),
          ),
        );
      },
    );

    test(
      'GET /me/likes reutiliza OfferModel',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [
              _offerJson(),
            ],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        final offers =
        await dataSource
            .getMyLikedOffers();

        expect(
          offers.single,
          isA<Offer>(),
        );

        expect(
          offers.single.jobTypeName,
          'Chofer',
        );
      },
    );

    test(
      'lista de favoritos vacia funciona',
          () async {
        final client =
        _TestApiClient(
          {
            'ok': true,
            'data': [],
          },
        );

        final dataSource =
        OffersRemoteDataSourceImpl(
          client.apiClient,
        );

        final offers =
        await dataSource
            .getMyLikedOffers();

        expect(
          offers,
          isEmpty,
        );
      },
    );
  });

  group('OffersRepository', () {
    test(
      'Repository delega getOfferById',
          () async {
        final dataSource =
        _FakeOffersRemoteDataSource();

        final repository =
        OffersRepositoryImpl(
          dataSource,
        );

        final offer =
        await repository
            .getOfferById(
          'offer-id',
        );

        expect(
          dataSource
              .getOfferByIdCalls,
          [
            'offer-id',
          ],
        );

        expect(
          offer,
          same(
            dataSource.offer,
          ),
        );
      },
    );

    test(
      'Repository delega applyToOffer',
          () async {
        final dataSource =
        _FakeOffersRemoteDataSource();

        final repository =
        OffersRepositoryImpl(
          dataSource,
        );

        const answers = [
          ApplyOfferAnswer(
            questionId: 'q1',
            value: 'Respuesta',
          ),
        ];

        final result =
        await repository
            .applyToOffer(
          offerId:
          'offer-id',
          comment:
          'Ejemplo',
          answers:
          answers,
        );

        expect(
          dataSource
              .applyCalls
              .single,
          _ApplyCall(
            offerId:
            'offer-id',
            comment:
            'Ejemplo',
            answers:
            answers,
          ),
        );

        expect(
          result,
          same(
            dataSource.result,
          ),
        );
      },
    );

    test(
      'Repository delega los tres metodos de likes',
          () async {
        final dataSource =
        _FakeOffersRemoteDataSource();

        final repository =
        OffersRepositoryImpl(
          dataSource,
        );

        await repository.likeOffer(
          'offer-id',
        );

        await repository.unlikeOffer(
          'offer-id',
        );

        await repository
            .getMyLikedOffers();

        expect(
          dataSource.likeCalls,
          [
            'offer-id',
          ],
        );

        expect(
          dataSource.unlikeCalls,
          [
            'offer-id',
          ],
        );

        expect(
          dataSource
              .getMyLikedOffersCalls,
          1,
        );
      },
    );

    test(
      'Repository delega getMyOffers',
          () async {
        final dataSource =
        _FakeOffersRemoteDataSource();

        final repository =
        OffersRepositoryImpl(
          dataSource,
        );

        final offers =
        await repository
            .getMyOffers();

        expect(
          offers,
          hasLength(1),
        );

        expect(
          offers.single,
          same(
            dataSource.offer,
          ),
        );
      },
    );
  });

  group('Offers providers', () {
    test(
      'el repositorio puede sustituirse mediante override',
          () {
        final fakeRepository =
        _FakeOffersRepository();

        final container =
        ProviderContainer(
          overrides: [
            offersRepositoryProvider
                .overrideWithValue(
              fakeRepository,
            ),
          ],
        );

        addTearDown(
          container.dispose,
        );

        expect(
          container.read(
            offersRepositoryProvider,
          ),
          same(
            fakeRepository,
          ),
        );
      },
    );
  });
}

Map<String, Object?> _jobTypeJson({
  String id =
  '6a445b6ca7eceacf02e1a107',
  String key = 'chofer',
  bool active = true,
  Object? customFields,
}) {
  return {
    'id': id,
    'key': key,
    'active': active,
    'createdAt':
    '2026-07-01T00:12:28+00:00',
    'updatedAt':
    '2026-07-07T23:12:58+00:00',
    'customFields':
    customFields ??
        [
          {
            'key':
            'categoria_licencia',
            'label':
            'Categoría de licencia',
            'type':
            'select',
            'required':
            true,
            'options': [
              '01',
              '02',
              '03',
              '04',
              '05',
            ],
          },
        ],
    'name': 'Chofer',
  };
}

Map<String, Object?> _offerJson({
  Object? deadline =
  '2026-08-30T00:00:00+00:00',
  Object? customAnswers,
  Object? questions,
  Object? payment,
  Object? location,
  String photo =
  'https://ocupa2.ia3x.com/media/imagen.png',
}) {
  return {
    'id':
    '6a4ef553021413b716070dc8',
    'jobTypeKey':
    'chofer',
    'jobTypeName':
    'Chofer',
    'contractType':
    'temporal',
    'description':
    'Se necesita chofer...',
    'address':
    'Santo Domingo, República Dominicana',
    'location':
    location ??
        {
          'lat':
          18.4861,
          'lng':
          -69.9312,
        },
    'payment':
    payment ??
        {
          'amount':
          35000,
          'currency':
          'DOP',
          'period':
          'total',
        },
    'photo':
    photo,
    'deadline':
    deadline,
    'customAnswers':
    customAnswers ??
        {
          'categoria_licencia':
          '03',
        },
    'questions':
    questions ??
        [
          {
            'id':
            'q1',
            'label':
            '¿Posee licencia categoría 03 vigente?',
            'type':
            'text',
            'required':
            true,
          },
        ],
    'status':
    'published',
    'applicantsCount':
    1,
    'likesCount':
    0,
    'createdAt':
    '2026-07-09T01:11:47+00:00',
    'updatedAt':
    '2026-07-09T01:11:47+00:00',
    'isIdentityRevealed':
    false,
    'likedByMe':
    false,
  };
}

Map<String, Object?>
_applyResultJson() {
  return {
    'ok': true,
    'data': {
      'id':
      'application-id',
      'status':
      'applied',
    },
  };
}

Map<String, Object?> _likeResultJson({
  bool liked = true,
  Object likesCount = 1,
}) {
  return {
    'ok': true,
    'data': {
      'liked':
      liked,
      'likesCount':
      likesCount,
    },
  };
}

class _TestApiClient {
  _TestApiClient(
      this.responseData,
      ) : conflictData = null {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (
            options,
            handler,
            ) {
          lastOptions =
              options;

          handler.resolve(
            Response<Object?>(
              requestOptions:
              options,
              statusCode:
              200,
              data:
              responseData,
            ),
          );
        },
      ),
    );
  }

  _TestApiClient.conflict(
      this.conflictData,
      ) : responseData = null {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (
            options,
            handler,
            ) {
          lastOptions =
              options;

          handler.reject(
            DioException(
              requestOptions:
              options,
              response:
              Response<Object?>(
                requestOptions:
                options,
                statusCode:
                409,
                data:
                conflictData,
              ),
              type:
              DioExceptionType
                  .badResponse,
            ),
          );
        },
      ),
    );
  }

  final Object? responseData;

  final Object? conflictData;

  final Dio dio =
  Dio(
    BaseOptions(
      baseUrl:
      'https://example.test',
    ),
  );

  late RequestOptions lastOptions;

  ApiClient get apiClient =>
      ApiClient(
        dio,
      );
}

class _FakeOffersRemoteDataSource
    implements OffersRemoteDataSource {
  final offer =
  OfferModel.fromJson(
    _offerJson(),
  );

  final result =
  ApplyOfferResultModel
      .fromApiResponse(
    _applyResultJson(),
  );

  final likeResult =
  OfferLikeResultModel
      .fromApiResponse(
    _likeResultJson(),
  );

  final getOfferByIdCalls =
  <String>[];

  final applyCalls =
  <_ApplyCall>[];

  final likeCalls =
  <String>[];

  final unlikeCalls =
  <String>[];

  int getMyLikedOffersCalls =
  0;

  @override
  Future<List<JobType>>
  getJobTypes() async {
    return const [];
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) {
    return Future.value(
      const [],
    );
  }

  @override
  Future<Offer> getOfferById(
      String id,
      ) async {
    getOfferByIdCalls.add(
      id,
    );

    return offer;
  }

  @override
  Future<ApplyOfferResult>
  applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer>
    answers,
  }) async {
    applyCalls.add(
      _ApplyCall(
        offerId:
        offerId,
        comment:
        comment,
        answers:
        answers,
      ),
    );

    return result;
  }

  @override
  Future<OfferLikeResult>
  likeOffer(
      String offerId,
      ) async {
    likeCalls.add(
      offerId,
    );

    return likeResult;
  }

  @override
  Future<OfferLikeResult>
  unlikeOffer(
      String offerId,
      ) async {
    unlikeCalls.add(
      offerId,
    );

    return const OfferLikeResult(
      liked:
      false,
      likesCount:
      0,
    );
  }

  @override
  Future<List<Offer>>
  getMyLikedOffers() async {
    getMyLikedOffersCalls++;

    return [
      offer,
    ];
  }

  @override
  Future<List<Offer>>
  getMyOffers() async {
    return [
      offer,
    ];
  }
}

class _ApplyCall {
  const _ApplyCall({
    required this.offerId,
    required this.comment,
    required this.answers,
  });

  final String offerId;

  final String comment;

  final List<ApplyOfferAnswer>
  answers;

  @override
  bool operator ==(
      Object other,
      ) {
    return other
    is _ApplyCall &&
        other.offerId ==
            offerId &&
        other.comment ==
            comment &&
        _listEquals(
          other.answers,
          answers,
        );
  }

  @override
  int get hashCode =>
      Object.hash(
        offerId,
        comment,
        Object.hashAll(
          answers,
        ),
      );
}

bool _listEquals<T>(
    List<T> a,
    List<T> b,
    ) {
  if (a.length !=
      b.length) {
    return false;
  }

  for (
  var index = 0;
  index < a.length;
  index++
  ) {
    if (a[index] !=
        b[index]) {
      return false;
    }
  }

  return true;
}

class _FakeOffersRepository
    implements OffersRepository {
  @override
  Future<List<JobType>>
  getJobTypes() async {
    return const [];
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    return const [];
  }

  @override
  Future<Offer> getOfferById(
      String id,
      ) async {
    return OfferModel.fromJson(
      _offerJson(),
    );
  }

  @override
  Future<ApplyOfferResult>
  applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer>
    answers,
  }) async {
    return ApplyOfferResultModel
        .fromApiResponse(
      _applyResultJson(),
    );
  }

  @override
  Future<OfferLikeResult>
  likeOffer(
      String offerId,
      ) async {
    return OfferLikeResultModel
        .fromApiResponse(
      _likeResultJson(),
    );
  }

  @override
  Future<OfferLikeResult>
  unlikeOffer(
      String offerId,
      ) async {
    return OfferLikeResultModel
        .fromApiResponse(
      _likeResultJson(
        liked: false,
      ),
    );
  }

  @override
  Future<List<Offer>>
  getMyLikedOffers() async {
    return const [];
  }

  @override
  Future<List<Offer>>
  getMyOffers() async {
    return const [];
  }
}