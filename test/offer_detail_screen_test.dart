import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/widgets/app_error_view.dart';
import 'package:ocupa2/core/widgets/app_loading.dart';
import 'package:ocupa2/features/applications/data/providers/applications_data_providers.dart';
import 'package:ocupa2/features/applications/domain/entities/application.dart';
import 'package:ocupa2/features/applications/domain/repositories/applications_repository.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_question.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/pages/offer_detail_screen.dart';
import 'package:ocupa2/features/offers/presentation/widgets/apply_offer_form.dart';

void main() {
  testWidgets('Loading inicial', (tester) async {
    final repository = _FakeOffersRepository()
      ..offerCompleter = Completer<Offer>();

    await tester.pumpWidget(_testDetail(repository));
    await tester.pump();

    expect(find.byType(AppLoading), findsOneWidget);
  });

  testWidgets('Error con reintento', (tester) async {
    final repository = _FakeOffersRepository()
      ..detailError = const ApiException(message: 'Fallo detalle');

    await tester.pumpWidget(_testDetail(repository));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Fallo detalle'), findsOneWidget);

    repository.detailError = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repository.detailCalls, 2);
    expect(find.text('Programador'), findsWidgets);
  });

  testWidgets('Informacion completa', (tester) async {
    await tester.pumpWidget(_testDetail(_FakeOffersRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Programador'), findsWidgets);
    expect(find.text('Temporal'), findsOneWidget);
    expect(find.text('Necesito un programador junior.'), findsOneWidget);
    expect(find.text('Santo Domingo'), findsOneWidget);
    expect(find.text('USD 50 - total'), findsOneWidget);
    expect(find.textContaining('Fecha limite'), findsOneWidget);
    expect(find.text('2 aplicantes'), findsOneWidget);
    expect(find.text('3 me gusta'), findsOneWidget);
    expect(find.text('published'), findsOneWidget);
    expect(find.text('turno: nocturno'), findsOneWidget);
  });

  testWidgets(
    'OfferDetailScreen conecta estado de like por offerId',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(likedByMe: true, likesCount: 6),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.text('6 me gusta'), findsOneWidget);
    },
  );

  testWidgets('Like en detalle actualiza contador', (tester) async {
    final repository = _FakeOffersRepository(
      offer: _offer(likedByMe: false, likesCount: 3),
    );

    await tester.pumpWidget(_testDetail(repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('Dar me gusta'));
    await tester.tap(find.byTooltip('Dar me gusta'));
    await tester.pumpAndSettle();

    expect(repository.likeCalls, ['offer-id']);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.text('4 me gusta'), findsOneWidget);
  });

  testWidgets('Imagen invalida muestra placeholder', (tester) async {
    await tester.pumpWidget(
      _testDetail(
        _FakeOffersRepository(
          offer: _offer(photo: 'string'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.work_outline_rounded), findsOneWidget);
  });

  testWidgets('Deadline null no renderiza fecha limite', (tester) async {
    await tester.pumpWidget(
      _testDetail(
        _FakeOffersRepository(
          offer: _offer(deadline: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Fecha limite'), findsNothing);
  });

  testWidgets('Deadline vencida muestra advertencia', (tester) async {
    await tester.pumpWidget(
      _testDetail(
        _FakeOffersRepository(
          offer: _offer(deadline: DateTime(2024)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('La fecha limite de esta oferta ya vencio.'),
      findsOneWidget,
    );
  });

  testWidgets('No muestra datos del publicante', (tester) async {
    await tester.pumpWidget(_testDetail(_FakeOffersRepository()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Empresa'), findsNothing);
    expect(find.textContaining('Telefono'), findsNothing);
    expect(find.textContaining('Correo'), findsNothing);
  });

  testWidgets('Pantalla pequena sin overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testDetail(_FakeOffersRepository()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Oferta sin preguntas permite aplicar', (tester) async {
    final repository = _FakeOffersRepository(
      offer: _offer(questions: const []),
    );

    await tester.pumpWidget(_testDetail(repository));
    await tester.pumpAndSettle();

    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(repository.applyCalls, 1);
    expect(repository.lastAnswers, isEmpty);
  });

  testWidgets(
    'Al abrir oferta A con aplicacion existente no aparece formulario',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      );

      repository.applicationsRepository.applications = [
        _application('offer-id'),
      ];

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      expect(find.text('Comentario'), findsNothing);
      expect(find.text('Enviar aplicacion'), findsNothing);
    },
  );

  testWidgets('Se muestra Ya aplicaste y status amigable', (tester) async {
    final repository = _FakeOffersRepository(
      offer: _offer(questions: const []),
    );

    repository.applicationsRepository.applications = [
      _application('offer-id', status: 'applied'),
    ];

    await tester.pumpWidget(_testDetail(repository));
    await tester.pumpAndSettle();

    expect(
      find.text('Ya aplicaste a esta oferta. Estado: Aplicada.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Oferta B sin aplicacion existente muestra formulario',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      );

      repository.applicationsRepository.applications = [
        _application('offer-a'),
      ];

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      expect(find.text('Comentario'), findsOneWidget);
      expect(find.text('Enviar aplicacion'), findsOneWidget);
    },
  );

  testWidgets('La comparacion usa offerId exacto', (tester) async {
    final repository = _FakeOffersRepository(
      offer: _offer(questions: const []),
    );

    repository.applicationsRepository.applications = [
      _application('offer-id-extra'),
    ];

    await tester.pumpWidget(_testDetail(repository));
    await tester.pumpAndSettle();

    expect(find.text('Enviar aplicacion'), findsOneWidget);
  });

  testWidgets(
    'Aplicaciones de otras ofertas no bloquean la actual',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      );

      repository.applicationsRepository.applications = [
        _application('other-offer'),
      ];

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      expect(find.text('Enviar aplicacion'), findsOneWidget);
    },
  );

  testWidgets(
    'Error al cargar aplicaciones no rompe el detalle',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      );

      repository.applicationsRepository.error = const ApiException(
        message: 'No fue posible cargar aplicaciones',
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      expect(find.text('Programador'), findsWidgets);
      expect(
        find.text('No fue posible cargar aplicaciones'),
        findsOneWidget,
      );
      expect(find.text('Enviar aplicacion'), findsOneWidget);
    },
  );

  testWidgets(
    'Pregunta text requerida muestra error y luego envia id',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(
          questions: const [
            OfferQuestion(
              id: 'q1',
              label: 'Experiencia',
              type: 'text',
              required: true,
              options: [],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await _tapSubmit(tester);
      await tester.pump();

      expect(
        find.text('Esta pregunta es obligatoria'),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.widgetWithText(
          TextFormField,
          'Experiencia *',
        ),
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Experiencia *',
        ),
        'Uno',
      );

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        repository.lastAnswers.single.questionId,
        'q1',
      );

      expect(
        repository.lastAnswers.single.value,
        'Uno',
      );
    },
  );

  testWidgets(
    'Pregunta date se envia yyyy-MM-dd',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(
          questions: const [
            OfferQuestion(
              id: 'q-date',
              label: 'Fecha disponible',
              type: 'date',
              required: true,
              options: [],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(
          TextFormField,
          'Fecha disponible *',
        ),
      );

      await tester.tap(
        find.widgetWithText(
          TextFormField,
          'Fecha disponible *',
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        repository.lastAnswers.single.questionId,
        'q-date',
      );

      expect(
        repository.lastAnswers.single.value,
        matches(r'^\d{4}-\d{2}-\d{2}$'),
      );
    },
  );

  testWidgets(
    'Pregunta select con options envia opcion',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(
          questions: const [
            OfferQuestion(
              id: 'q-select',
              label: 'Turno',
              type: 'select',
              required: true,
              options: ['Dia', 'Noche'],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<String>),
      );

      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Noche').last);
      await tester.pumpAndSettle();

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        repository.lastAnswers.single.value,
        'Noche',
      );
    },
  );

  testWidgets(
    'Select sin options no rompe e impide enviar si es requerida',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(
          questions: const [
            OfferQuestion(
              id: 'q-select',
              label: 'Turno',
              type: 'select',
              required: true,
              options: [],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      expect(
        find.text('Sin opciones disponibles'),
        findsOneWidget,
      );

      await _tapSubmit(tester);
      await tester.pump();

      expect(
        find.text(
          'No hay opciones disponibles para esta pregunta requerida',
        ),
        findsOneWidget,
      );

      expect(repository.applyCalls, 0);
    },
  );

  testWidgets(
    'Pregunta check false se considera respuesta valida',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(
          questions: const [
            OfferQuestion(
              id: 'q-check',
              label: 'Acepto horario',
              type: 'check',
              required: true,
              options: [],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byType(CheckboxListTile),
      );

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        repository.lastAnswers.single.value,
        'false',
      );
    },
  );

  testWidgets(
    'Tipo desconocido usa texto generico',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(
          questions: const [
            OfferQuestion(
              id: 'q-unknown',
              label: 'Otra pregunta',
              type: 'rating',
              required: true,
              options: [],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(
          TextFormField,
          'Otra pregunta *',
        ),
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Otra pregunta *',
        ),
        'Valor',
      );

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        repository.lastAnswers.single.questionId,
        'q-unknown',
      );

      expect(
        repository.lastAnswers.single.value,
        'Valor',
      );
    },
  );

  testWidgets(
    'Comentario se envia con trim',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
        '  Hola  ',
      );

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(repository.lastComment, 'Hola');
    },
  );

  testWidgets(
    'Loading deshabilita submit y evita doble submit',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      )..applyCompleter = Completer<ApplyOfferResult>();

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await _tapSubmit(tester);
      await _tapSubmit(tester);
      await tester.pump();

      expect(repository.applyCalls, 1);

      expect(
        tester.widget<FilledButton>(
          find.byType(FilledButton),
        ).onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'Exito muestra confirmacion y evita segunda aplicacion',
        (tester) async {
      await tester.pumpWidget(
        _testDetail(
          _FakeOffersRepository(
            offer: _offer(questions: const []),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('correctamente.'),
        findsOneWidget,
      );

      expect(
        find.text('Ya aplicaste a esta oferta.'),
        findsOneWidget,
      );

      expect(
        find.text('Enviar aplicacion'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Error 409 muestra mensaje exacto y conserva datos',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      )..applyError = const ApiException(
        message: 'Ya aplicaste a esta oferta.',
        statusCode: 409,
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
        'Mi respuesta',
      );

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Ya aplicaste a esta oferta.'),
        findsWidgets,
      );

      expect(
        find.text('Enviar aplicacion'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Error conserva datos y permite reintentar',
        (tester) async {
      final repository = _FakeOffersRepository(
        offer: _offer(questions: const []),
      )..applyError = const ApiException(
        message: 'Error temporal',
      );

      await tester.pumpWidget(_testDetail(repository));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
        'Mi respuesta',
      );

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Error temporal'),
        findsOneWidget,
      );

      expect(
        find.text('Mi respuesta'),
        findsOneWidget,
      );

      repository.applyError = null;

      await _tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(repository.applyCalls, 2);
    },
  );

  testWidgets(
    'Teclado y scroll funcionan',
        (tester) async {
      tester.view.physicalSize = const Size(320, 520);
      tester.view.devicePixelRatio = 1;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _testDetail(_FakeOffersRepository()),
      );

      await tester.pumpAndSettle();

      await tester.showKeyboard(
        find.widgetWithText(
          TextFormField,
          'Comentario',
        ),
      );

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -240),
      );

      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Formulario de B permanece habilitado tras aplicar a A',
        (tester) async {
      await tester.pumpWidget(
        _testForm(
          offer: _offer(
            id: 'offer-a',
            questions: const [],
          ),
          successMessage: 'Aplicacion enviada correctamente.',
        ),
      );

      expect(
        find.text('Enviar aplicacion'),
        findsNothing,
      );

      await tester.pumpWidget(
        _testForm(
          offer: _offer(
            id: 'offer-b',
            questions: const [],
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('Enviar aplicacion'),
        findsOneWidget,
      );

      expect(
        tester.widget<FilledButton>(
          find.byType(FilledButton),
        ).onPressed,
        isNotNull,
      );
    },
  );
}

Widget _testDetail(_FakeOffersRepository repository) {
  return ProviderScope(
    overrides: [
      offersRepositoryProvider.overrideWithValue(repository),
      applicationsRepositoryProvider.overrideWithValue(
        repository.applicationsRepository,
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const OfferDetailScreen(
        offerId: 'offer-id',
      ),
    ),
  );
}

Widget _testForm({
  required Offer offer,
  String? successMessage,
  ApiException? error,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: ApplyOfferForm(
        key: ValueKey<String>(offer.id),
        offer: offer,
        isSubmitting: false,
        error: error,
        successMessage: successMessage,
        hasAlreadyApplied: successMessage != null,
        existingApplicationStatus: null,
        onSubmit: (_, _) async => true,
      ),
    ),
  );
}

const _deadlineUnset = Object();

Offer _offer({
  String id = 'offer-id',
  String photo = 'https://ocupa2.ia3x.com/media/imagen.jpg',
  Object? deadline = _deadlineUnset,
  bool likedByMe = false,
  int likesCount = 3,
  List<OfferQuestion> questions = const [
    OfferQuestion(
      id: 'q1',
      label: 'Tienes experiencia',
      type: 'text',
      required: true,
      options: [],
    ),
  ],
}) {
  return Offer(
    id: id,
    jobTypeKey: 'programador',
    jobTypeName: 'Programador',
    contractType: 'temporal',
    description: 'Necesito un programador junior.',
    address: 'Santo Domingo',
    location: const OfferLocation(
      lat: 18.4,
      lng: -69.9,
    ),
    payment: const OfferPayment(
      amount: 50,
      currency: 'USD',
      period: 'total',
    ),
    photo: photo,
    deadline: identical(deadline, _deadlineUnset)
        ? DateTime(2026, 10, 30)
        : deadline as DateTime?,
    customAnswers: const {
      'turno': 'nocturno',
      'vacio': '',
    },
    questions: questions,
    status: 'published',
    applicantsCount: 2,
    likesCount: likesCount,
    createdAt: DateTime(2026, 8, 3),
    updatedAt: DateTime(2026, 8, 3),
    isIdentityRevealed: false,
    likedByMe: likedByMe,
  );
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final button = find.text('Enviar aplicacion');

  await tester.ensureVisible(button);
  await tester.tap(button);
}

class _FakeOffersRepository implements OffersRepository {
  _FakeOffersRepository({Offer? offer})
      : offer = offer ?? _offer();

  Offer offer;

  final applicationsRepository =
  _FakeApplicationsRepository();

  Object? detailError;
  Object? applyError;

  Completer<Offer>? offerCompleter;
  Completer<ApplyOfferResult>? applyCompleter;

  int detailCalls = 0;
  int applyCalls = 0;

  final likeCalls = <String>[];
  final unlikeCalls = <String>[];

  String? lastOfferId;
  String? lastComment;

  List<ApplyOfferAnswer> lastAnswers = const [];

  @override
  Future<List<JobType>> getJobTypes() async {
    return const [];
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) {
    return Future.value([offer]);
  }

  @override
  Future<Offer> createOffer(dynamic request) {
    throw UnimplementedError();
  }

  @override
  Future<Offer> getOfferById(String id) {
    detailCalls++;
    lastOfferId = id;

    if (detailError != null) {
      throw detailError!;
    }

    return offerCompleter?.future ??
        Future.value(offer);
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) {
    applyCalls++;
    lastOfferId = offerId;
    lastComment = comment;
    lastAnswers = answers;

    if (applyError != null) {
      throw applyError!;
    }

    return applyCompleter?.future ??
        Future.value(
          const ApplyOfferResult(
            id: 'application-id',
            status: 'applied',
          ),
        );
  }

  @override
  Future<OfferLikeResult> likeOffer(
      String offerId,
      ) async {
    likeCalls.add(offerId);

    return const OfferLikeResult(
      liked: true,
      likesCount: 4,
    );
  }

  @override
  Future<OfferLikeResult> unlikeOffer(
      String offerId,
      ) async {
    unlikeCalls.add(offerId);

    return const OfferLikeResult(
      liked: false,
      likesCount: 3,
    );
  }

  @override
  Future<List<Offer>> getMyLikedOffers() async {
    return const [];
  }
}

class _FakeApplicationsRepository
    implements ApplicationsRepository {
  List<Application> applications = const [];

  Object? error;

  int calls = 0;

  @override
  Future<List<Application>> getMyApplications() async {
    calls++;

    if (error != null) {
      throw error!;
    }

    return applications;
  }

  @override
  Future<List<Application>> getOfferApplications(
      String offerId,
      ) async {
    return applications;
  }

  @override
  Future<Application> updateApplication({
    required String applicationId,
    int? rating,
    String? status,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  }) async {
    if (error != null) {
      throw error!;
    }

    return applications.firstWhere(
          (application) =>
      application.id == applicationId,
      orElse: () => throw StateError(
        'Aplicación no encontrada: $applicationId',
      ),
    );
  }
}

Application _application(
    String offerId, {
      String status = 'applied',
    }) {
  return Application(
    id: 'application-$offerId',
    offerId: offerId,
    applicantId: 'applicant-id',
    comment: 'Comentario',
    answers: const [],
    status: status,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}