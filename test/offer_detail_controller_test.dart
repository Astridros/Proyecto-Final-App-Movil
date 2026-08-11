import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/conflict_exception.dart';
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
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/providers/offer_detail_controller.dart';
import 'package:ocupa2/features/offers/presentation/providers/offer_detail_providers.dart';
import 'package:ocupa2/features/offers/presentation/providers/offer_detail_state.dart';

void main() {
  test('Estado inicial', () {
    final setup = _setup();

    final state = setup.state;

    expect(state.isInitialLoading, isFalse);
    expect(state.isSubmitting, isFalse);
    expect(state.offer, isNull);
    expect(state.applicationResult, isNull);
    expect(state.error, isNull);
    expect(state.successMessage, isNull);
    expect(state.hasOffer, isFalse);
    expect(state.hasAppliedSuccessfully, isFalse);
  });

  test('loadOffer activa/desactiva loading', () async {
    final setup = _setup();
    final completer = Completer<Offer>();
    setup.repository.offerCompleters.add(completer);

    final future = setup.notifier.loadOffer('offer-id');

    expect(setup.state.isInitialLoading, isTrue);
    completer.complete(_offer('offer-id'));
    await future;

    expect(setup.state.isInitialLoading, isFalse);
  });

  test('loadOffer guarda oferta', () async {
    final setup = _setup(offer: _offer('loaded'));

    await setup.notifier.loadOffer('loaded');

    expect(setup.state.offer?.id, 'loaded');
    expect(setup.state.hasOffer, isTrue);
  });

  test('loadOffer guarda AppException', () async {
    final setup = _setup();
    setup.repository.getOfferError = const ApiException(message: 'Fallo');

    await setup.notifier.loadOffer('offer-id');

    expect(setup.state.error, isA<ApiException>());
    expect(setup.state.isInitialLoading, isFalse);
  });

  test('Evita carga duplicada', () async {
    final setup = _setup();
    final completer = Completer<Offer>();
    setup.repository.offerCompleters.add(completer);

    final firstFuture = setup.notifier.loadOffer('offer-id');
    final secondFuture = setup.notifier.loadOffer('other-id');

    expect(setup.repository.getOfferByIdCalls, ['offer-id']);
    completer.complete(_offer('offer-id'));
    await Future.wait([firstFuture, secondFuture]);
  });

  test('apply sin oferta cargada falla de forma controlada', () async {
    final setup = _setup();

    final result = await setup.notifier.apply(
      comment: 'Hola',
      answers: const [],
    );

    expect(result, isFalse);
    expect(setup.state.error, isA<ApiException>());
    expect(setup.repository.applyCalls, isEmpty);
  });

  test('apply envía comment y answers', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');
    const answers = [ApplyOfferAnswer(questionId: 'q1', value: 'Sí')];

    await setup.notifier.apply(comment: 'Comentario', answers: answers);

    expect(
      setup.repository.applyCalls.single,
      const _ApplyCall(
        offerId: 'offer-id',
        comment: 'Comentario',
        answers: answers,
      ),
    );
  });

  test('apply guarda resultado', () async {
    final setup = _setup(
      result: const ApplyOfferResult(id: 'application-id', status: 'applied'),
    );
    await setup.notifier.loadOffer('offer-id');

    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    expect(setup.state.applicationResult?.id, 'application-id');
    expect(setup.state.hasAppliedSuccessfully, isTrue);
  });

  test('apply devuelve true en éxito', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');

    final result = await setup.notifier.apply(
      comment: 'Comentario',
      answers: const [],
    );

    expect(result, isTrue);
    expect(setup.state.successMessage, 'Aplicación enviada correctamente.');
  });

  test('apply devuelve false en error', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');
    setup.repository.applyError = const ApiException(message: 'Fallo');

    final result = await setup.notifier.apply(
      comment: 'Comentario',
      answers: const [],
    );

    expect(result, isFalse);
    expect(setup.state.error, isA<ApiException>());
  });

  test('Error 409 conserva mensaje', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');
    setup.repository.applyError = const ConflictException(
      message: 'Ya aplicaste a esta oferta.',
      statusCode: 409,
    );

    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    expect(setup.state.error?.message, 'Ya aplicaste a esta oferta.');
  });

  test('Evita doble submit', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');
    final completer = Completer<ApplyOfferResult>();
    setup.repository.applyCompleters.add(completer);

    final firstFuture = setup.notifier.apply(comment: 'Uno', answers: const []);
    final secondFuture = setup.notifier.apply(
      comment: 'Dos',
      answers: const [],
    );

    expect(setup.repository.applyCalls, hasLength(1));
    completer.complete(const ApplyOfferResult(id: 'app-id', status: 'applied'));
    final results = await Future.wait([firstFuture, secondFuture]);

    expect(results, [true, false]);
  });

  test('isSubmitting vuelve a false', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');

    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    expect(setup.state.isSubmitting, isFalse);
  });

  test('clearError', () async {
    final setup = _setup();
    setup.repository.getOfferError = const ApiException(message: 'Fallo');
    await setup.notifier.loadOffer('offer-id');

    setup.notifier.clearError();

    expect(setup.state.error, isNull);
  });

  test('clearSuccessMessage', () async {
    final setup = _setup();
    await setup.notifier.loadOffer('offer-id');
    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    setup.notifier.clearSuccessMessage();

    expect(setup.state.successMessage, isNull);
  });

  test('Provider override', () {
    final repository = _FakeOffersRepository();
    final container = ProviderContainer(
      overrides: [offersRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(offersRepositoryProvider), same(repository));
  });

  test(
    'Aplicar correctamente a oferta A establece estado aplicado para A',
    () async {
      final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
      await setup.notifier.loadOffer();

      await setup.notifier.apply(comment: 'Comentario', answers: const []);

      expect(setup.state.applicationResult?.id, 'app-id');
      expect(setup.state.hasAppliedSuccessfully, isTrue);
    },
  );

  test('Abrir oferta B no conserva applicationResult de A', () async {
    final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
    await setup.notifier.loadOffer();
    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    final bState = setup.container.read(
      offerDetailControllerProvider('offer-b'),
    );

    expect(bState.applicationResult, isNull);
    expect(bState.hasAppliedSuccessfully, isFalse);
  });

  test('Abrir oferta B no conserva successMessage de A', () async {
    final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
    await setup.notifier.loadOffer();
    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    final bState = setup.container.read(
      offerDetailControllerProvider('offer-b'),
    );

    expect(bState.successMessage, isNull);
  });

  test('Error 409 en oferta A no bloquea oferta B', () async {
    final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
    await setup.notifier.loadOffer();
    setup.repository.applyError = const ConflictException(
      message: 'Ya aplicaste a esta oferta.',
      statusCode: 409,
    );

    await setup.notifier.apply(comment: 'Comentario', answers: const []);

    final bState = setup.container.read(
      offerDetailControllerProvider('offer-b'),
    );

    expect(setup.state.error?.message, 'Ya aplicaste a esta oferta.');
    expect(bState.error, isNull);
    expect(bState.applicationResult, isNull);
    expect(bState.successMessage, isNull);
  });

  test(
    'Volver a oferta A conserva su estado aplicado en la misma instancia',
    () async {
      final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
      await setup.notifier.loadOffer();
      await setup.notifier.apply(comment: 'Comentario', answers: const []);
      setup.container.read(offerDetailControllerProvider('offer-b'));

      final aState = setup.container.read(
        offerDetailControllerProvider('offer-a'),
      );

      expect(aState.applicationResult?.id, 'app-id');
      expect(aState.hasAppliedSuccessfully, isTrue);
    },
  );

  test(
    'Providers family con ids diferentes mantienen estados independientes',
    () async {
      final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
      await setup.notifier.loadOffer();
      await setup.notifier.apply(comment: 'Comentario', answers: const []);

      final aState = setup.container.read(
        offerDetailControllerProvider('offer-a'),
      );
      final bState = setup.container.read(
        offerDetailControllerProvider('offer-b'),
      );

      expect(aState.applicationResult, isNotNull);
      expect(bState.applicationResult, isNull);
      expect(bState.hasAlreadyApplied, isFalse);
      expect(bState.successMessage, isNull);
      expect(bState.error, isNull);
    },
  );

  test('loadOffer detecta aplicacion existente por offerId exacto', () async {
    final setup = _setup(offerId: 'offer-a', offer: _offer('offer-a'));
    setup.applicationsRepository.applications = [
      _application('offer-a', status: 'applied'),
    ];

    await setup.notifier.loadOffer();

    expect(setup.state.hasAlreadyApplied, isTrue);
    expect(setup.state.existingApplication?.offerId, 'offer-a');
  });

  test('aplicaciones de otras ofertas no bloquean la actual', () async {
    final setup = _setup(offerId: 'offer-b', offer: _offer('offer-b'));
    setup.applicationsRepository.applications = [_application('offer-a')];

    await setup.notifier.loadOffer();

    expect(setup.state.hasAlreadyApplied, isFalse);
    expect(setup.state.existingApplication, isNull);
  });

  test(
    'error al cargar aplicaciones conserva detalle sin asumir aplicado',
    () async {
      final setup = _setup();
      setup.applicationsRepository.error = const ApiException(
        message: 'Fallo aplicaciones',
      );

      await setup.notifier.loadOffer();

      expect(setup.state.offer?.id, 'offer-id');
      expect(setup.state.hasAlreadyApplied, isFalse);
      expect(setup.state.error?.message, 'Fallo aplicaciones');
    },
  );

  test(
    'al recibir 409 se marca permanentemente como ya aplicada en ese estado',
    () async {
      final setup = _setup();
      await setup.notifier.loadOffer();
      setup.repository.applyError = const ConflictException(
        message: 'Ya aplicaste a esta oferta.',
        statusCode: 409,
      );

      await setup.notifier.apply(comment: 'Comentario', answers: const []);

      expect(setup.state.hasAlreadyApplied, isTrue);
      expect(setup.state.error?.message, 'Ya aplicaste a esta oferta.');
    },
  );

  test('copyWith permite limpiar campos opcionales', () {
    final state = OfferDetailState(
      isInitialLoading: false,
      isSubmitting: false,
      offer: _offer('offer-id'),
      applicationResult: const ApplyOfferResult(
        id: 'app-id',
        status: 'applied',
      ),
      hasAlreadyApplied: true,
      existingApplication: _application('offer-id'),
      error: const ApiException(message: 'Fallo'),
      successMessage: 'Listo',
    );

    final next = state.copyWith(
      offer: null,
      applicationResult: null,
      hasAlreadyApplied: false,
      existingApplication: null,
      error: null,
      successMessage: null,
    );

    expect(next.offer, isNull);
    expect(next.applicationResult, isNull);
    expect(next.hasAlreadyApplied, isFalse);
    expect(next.existingApplication, isNull);
    expect(next.error, isNull);
    expect(next.successMessage, isNull);
  });
}

_Setup _setup({
  String offerId = 'offer-id',
  Offer? offer,
  ApplyOfferResult? result,
}) {
  final repository = _FakeOffersRepository(
    offer: offer ?? _offer('offer-id'),
    result: result ?? const ApplyOfferResult(id: 'app-id', status: 'applied'),
  );
  final applicationsRepository = _FakeApplicationsRepository();
  final container = ProviderContainer(
    overrides: [
      offersRepositoryProvider.overrideWithValue(repository),
      applicationsRepositoryProvider.overrideWithValue(applicationsRepository),
    ],
  );
  addTearDown(container.dispose);

  return _Setup(
    container: container,
    repository: repository,
    applicationsRepository: applicationsRepository,
    offerId: offerId,
  );
}

Offer _offer(String id) {
  return Offer(
    id: id,
    jobTypeKey: 'programador',
    jobTypeName: 'Programador',
    contractType: 'temporal',
    description: 'Oferta de prueba',
    address: 'Santo Domingo',
    location: const OfferLocation(lat: 18.4, lng: -69.9),
    payment: const OfferPayment(amount: 50, currency: 'USD', period: 'total'),
    photo: 'string',
    customAnswers: const {},
    questions: const [],
    status: 'published',
    applicantsCount: 0,
    likesCount: 0,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isIdentityRevealed: false,
    likedByMe: false,
  );
}

class _Setup {
  const _Setup({
    required this.container,
    required this.repository,
    required this.applicationsRepository,
    required this.offerId,
  });

  final ProviderContainer container;
  final _FakeOffersRepository repository;
  final _FakeApplicationsRepository applicationsRepository;
  final String offerId;

  OfferDetailState get state =>
      container.read(offerDetailControllerProvider(offerId));

  OfferDetailController get notifier =>
      container.read(offerDetailControllerProvider(offerId).notifier);
}

class _FakeOffersRepository implements OffersRepository {
  _FakeOffersRepository({Offer? offer, ApplyOfferResult? result})
    : offer = offer ?? _offer('offer-id'),
      result =
          result ?? const ApplyOfferResult(id: 'app-id', status: 'applied');

  final Offer offer;
  final ApplyOfferResult result;
  final offerCompleters = Queue<Completer<Offer>>();
  final applyCompleters = Queue<Completer<ApplyOfferResult>>();
  final getOfferByIdCalls = <String>[];
  final applyCalls = <_ApplyCall>[];
  Object? getOfferError;
  Object? applyError;

  @override
  Future<List<JobType>> getJobTypes() async {
    return const [];
  }

  @override
  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType}) {
    return Future.value(const []);
  }

  @override
  Future<Offer> createOffer(dynamic request) {
    throw UnimplementedError();
  }

  @override
  Future<Offer> getOfferById(String id) async {
    getOfferByIdCalls.add(id);
    if (getOfferError != null) {
      throw getOfferError!;
    }

    if (offerCompleters.isNotEmpty) {
      return offerCompleters.removeFirst().future;
    }

    return offer;
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) async {
    applyCalls.add(
      _ApplyCall(offerId: offerId, comment: comment, answers: answers),
    );

    if (applyError != null) {
      throw applyError!;
    }

    if (applyCompleters.isNotEmpty) {
      return applyCompleters.removeFirst().future;
    }

    return result;
  }

  @override
  Future<OfferLikeResult> likeOffer(String offerId) async {
    return const OfferLikeResult(liked: true, likesCount: 1);
  }

  @override
  Future<OfferLikeResult> unlikeOffer(String offerId) async {
    return const OfferLikeResult(liked: false, likesCount: 0);
  }

  @override
  Future<List<Offer>> getMyLikedOffers() async {
    return const [];
  }
}

class _FakeApplicationsRepository implements ApplicationsRepository {
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
}

class _ApplyCall {
  const _ApplyCall({
    required this.offerId,
    required this.comment,
    required this.answers,
  });

  final String offerId;
  final String comment;
  final List<ApplyOfferAnswer> answers;

  @override
  bool operator ==(Object other) {
    return other is _ApplyCall &&
        other.offerId == offerId &&
        other.comment == comment &&
        _listEquals(other.answers, answers);
  }

  @override
  int get hashCode => Object.hash(offerId, comment, Object.hashAll(answers));
}

Application _application(String offerId, {String status = 'applied'}) {
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

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }

  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }

  return true;
}
