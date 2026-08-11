import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/validation_exception.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/constants/contract_types.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/providers/offers_controller.dart';
import 'package:ocupa2/features/offers/presentation/providers/offers_presentation_providers.dart';
import 'package:ocupa2/features/offers/presentation/providers/offers_state.dart';

void main() {
  test('estado inicial correcto', () {
    final setup = _setup();

    final state = setup.container.read(offersControllerProvider);

    expect(state.isInitialLoading, isFalse);
    expect(state.isRefreshing, isFalse);
    expect(state.isFiltering, isFalse);
    expect(state.jobTypes, isEmpty);
    expect(state.offers, isEmpty);
    expect(state.selectedJobTypeKey, isNull);
    expect(state.selectedContractType, isNull);
    expect(state.error, isNull);
  });

  test('loadInitial consulta job types y ofertas', () async {
    final setup = _setup();

    await setup.notifier.loadInitial();

    expect(setup.repository.jobTypeCalls, 1);
    expect(setup.repository.offerCalls, hasLength(1));
  });

  test('loadInitial expone solo job types activos', () async {
    final setup = _setup(
      jobTypes: [_jobType('chofer'), _jobType('inactivo', active: false)],
    );

    await setup.notifier.loadInitial();

    expect(setup.state.jobTypes, hasLength(1));
    expect(setup.state.jobTypes.single.key, 'chofer');
  });

  test('loadInitial carga ofertas sin filtros', () async {
    final setup = _setup(offers: [_offer('uno')]);

    await setup.notifier.loadInitial();

    expect(setup.state.offers.single.id, 'uno');
    expect(setup.repository.offerCalls.single, const _OfferCall());
  });

  test('loadInitial establece y limpia isInitialLoading', () async {
    final setup = _setup();
    final jobTypesCompleter = Completer<List<JobType>>();
    final offersCompleter = Completer<List<Offer>>();
    setup.repository.jobTypeCompleters.add(jobTypesCompleter);
    setup.repository.offerCompleters.add(offersCompleter);

    final future = setup.notifier.loadInitial();

    expect(setup.state.isInitialLoading, isTrue);
    jobTypesCompleter.complete([_jobType('chofer')]);
    offersCompleter.complete([_offer('uno')]);
    await future;

    expect(setup.state.isInitialLoading, isFalse);
  });

  test('error inicial se guarda como AppException', () async {
    final setup = _setup();
    setup.repository.jobTypesError = const ApiException(message: 'Fallo');

    await setup.notifier.loadInitial();

    expect(setup.state.error, isA<ApiException>());
    expect(setup.state.isInitialLoading, isFalse);
  });

  test('refresh conserva datos mientras carga', () async {
    final setup = _setup(offers: [_offer('inicial')]);
    await setup.notifier.loadInitial();
    final jobTypesCompleter = Completer<List<JobType>>();
    final offersCompleter = Completer<List<Offer>>();
    setup.repository.jobTypeCompleters.add(jobTypesCompleter);
    setup.repository.offerCompleters.add(offersCompleter);

    final future = setup.notifier.refresh();

    expect(setup.state.isRefreshing, isTrue);
    expect(setup.state.offers.single.id, 'inicial');
    jobTypesCompleter.complete([_jobType('chofer')]);
    offersCompleter.complete([_offer('actualizada')]);
    await future;
  });

  test('refresh utiliza filtros actuales', () async {
    final setup = _setup();
    await setup.notifier.changeJobType('chofer');
    await setup.notifier.changeContractType(ContractTypes.temporal);
    setup.repository.offerCalls.clear();

    await setup.notifier.refresh();

    expect(
      setup.repository.offerCalls.single,
      const _OfferCall(jobTypeKey: 'chofer', contractType: 'temporal'),
    );
  });

  test('refresh mantiene datos previos cuando falla', () async {
    final setup = _setup(offers: [_offer('inicial')]);
    await setup.notifier.loadInitial();
    setup.repository.offersError = const ApiException(message: 'Fallo');

    await setup.notifier.refresh();

    expect(setup.state.offers.single.id, 'inicial');
    expect(setup.state.error, isA<ApiException>());
  });

  test('changeJobType envía el jobTypeKey correcto', () async {
    final setup = _setup();

    await setup.notifier.changeJobType('chofer');

    expect(setup.repository.offerCalls.single.jobTypeKey, 'chofer');
    expect(setup.state.selectedJobTypeKey, 'chofer');
  });

  test('changeJobType convierte string vacío en null', () async {
    final setup = _setup();
    await setup.notifier.changeJobType('chofer');
    setup.repository.offerCalls.clear();

    await setup.notifier.changeJobType('  ');

    expect(setup.repository.offerCalls.single.jobTypeKey, isNull);
    expect(setup.state.selectedJobTypeKey, isNull);
  });

  test('changeJobType no repite petición si no cambia', () async {
    final setup = _setup();

    await setup.notifier.changeJobType('chofer');
    await setup.notifier.changeJobType(' chofer ');

    expect(setup.repository.offerCalls, hasLength(1));
  });

  test('changeContractType acepta temporal', () async {
    final setup = _setup();

    await setup.notifier.changeContractType(ContractTypes.temporal);

    expect(setup.repository.offerCalls.single.contractType, 'temporal');
  });

  test('changeContractType acepta fijo', () async {
    final setup = _setup();

    await setup.notifier.changeContractType(ContractTypes.fijo);

    expect(setup.repository.offerCalls.single.contractType, 'fijo');
  });

  test('changeContractType acepta horas', () async {
    final setup = _setup();

    await setup.notifier.changeContractType(ContractTypes.horas);

    expect(setup.repository.offerCalls.single.contractType, 'horas');
  });

  test('changeContractType convierte string vacío en null', () async {
    final setup = _setup();
    await setup.notifier.changeContractType(ContractTypes.temporal);
    setup.repository.offerCalls.clear();

    await setup.notifier.changeContractType('');

    expect(setup.repository.offerCalls.single.contractType, isNull);
    expect(setup.state.selectedContractType, isNull);
  });

  test('contractType inválido no llama al repositorio', () async {
    final setup = _setup();

    await setup.notifier.changeContractType('permanent');

    expect(setup.repository.offerCalls, isEmpty);
    expect(setup.state.error, isA<ValidationException>());
  });

  test('filtros combinados envían ambos valores', () async {
    final setup = _setup();

    await setup.notifier.changeJobType('chofer');
    await setup.notifier.changeContractType(ContractTypes.temporal);

    expect(
      setup.repository.offerCalls.last,
      const _OfferCall(jobTypeKey: 'chofer', contractType: 'temporal'),
    );
  });

  test('clearFilters realiza una sola petición sin filtros', () async {
    final setup = _setup();
    await setup.notifier.changeJobType('chofer');
    await setup.notifier.changeContractType(ContractTypes.temporal);
    setup.repository.offerCalls.clear();

    await setup.notifier.clearFilters();

    expect(setup.repository.offerCalls, [const _OfferCall()]);
    expect(setup.state.selectedJobTypeKey, isNull);
    expect(setup.state.selectedContractType, isNull);
  });

  test('clearFilters no consulta si ya estaban limpios', () async {
    final setup = _setup();

    await setup.notifier.clearFilters();

    expect(setup.repository.offerCalls, isEmpty);
  });

  test('un error al filtrar conserva ofertas anteriores', () async {
    final setup = _setup(offers: [_offer('inicial')]);
    await setup.notifier.loadInitial();
    setup.repository.offersError = const ApiException(message: 'Fallo');

    await setup.notifier.changeJobType('chofer');

    expect(setup.state.offers.single.id, 'inicial');
    expect(setup.state.error, isA<ApiException>());
  });

  test('clearError elimina el error', () async {
    final setup = _setup();
    setup.repository.offersError = const ApiException(message: 'Fallo');
    await setup.notifier.changeJobType('chofer');

    setup.notifier.clearError();

    expect(setup.state.error, isNull);
  });

  test(
    'dos cambios rápidos no permiten respuesta vieja sobrescriba la nueva',
        () async {
      final setup = _setup();
      final firstCompleter = Completer<List<Offer>>();
      final secondCompleter = Completer<List<Offer>>();
      setup.repository.offerCompleters
        ..add(firstCompleter)
        ..add(secondCompleter);

      final firstFuture = setup.notifier.changeJobType('chofer');
      final secondFuture = setup.notifier.changeJobType('cocina');
      secondCompleter.complete([_offer('nueva')]);
      await secondFuture;
      firstCompleter.complete([_offer('vieja')]);
      await firstFuture;

      expect(setup.state.selectedJobTypeKey, 'cocina');
      expect(setup.state.offers.single.id, 'nueva');
    },
  );

  test('isFiltering vuelve a false después del éxito', () async {
    final setup = _setup();
    final completer = Completer<List<Offer>>();
    setup.repository.offerCompleters.add(completer);

    final future = setup.notifier.changeJobType('chofer');
    expect(setup.state.isFiltering, isTrue);
    completer.complete([_offer('uno')]);
    await future;

    expect(setup.state.isFiltering, isFalse);
  });

  test('isFiltering vuelve a false después de un error', () async {
    final setup = _setup();
    setup.repository.offersError = const ApiException(message: 'Fallo');

    await setup.notifier.changeJobType('chofer');

    expect(setup.state.isFiltering, isFalse);
  });

  test('isRefreshing vuelve a false después de un error', () async {
    final setup = _setup(offers: [_offer('inicial')]);
    await setup.notifier.loadInitial();
    setup.repository.offersError = const ApiException(message: 'Fallo');

    await setup.notifier.refresh();

    expect(setup.state.isRefreshing, isFalse);
  });

  test('las listas del estado no pueden mutarse externamente', () async {
    final setup = _setup(offers: [_offer('uno')]);
    await setup.notifier.loadInitial();

    expect(() => setup.state.offers.add(_offer('dos')), throwsUnsupportedError);
    expect(
          () => setup.state.jobTypes.add(_jobType('nuevo')),
      throwsUnsupportedError,
    );
  });
}

_ControllerSetup _setup({List<JobType>? jobTypes, List<Offer>? offers}) {
  final repository = _FakeOffersRepository(
    jobTypes: jobTypes ?? [_jobType('chofer')],
    offers: offers ?? [_offer('uno')],
  );
  final container = ProviderContainer(
    overrides: [offersRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

  return _ControllerSetup(container: container, repository: repository);
}

JobType _jobType(String key, {bool active = true}) {
  return JobType(
    id: '$key-id',
    key: key,
    name: key,
    active: active,
    customFields: const [],
    createdAt: DateTime(2026),
  );
}

Offer _offer(String id) {
  return Offer(
    id: id,
    jobTypeKey: 'chofer',
    jobTypeName: 'Chofer',
    contractType: 'temporal',
    description: 'Oferta de prueba',
    address: 'Santo Domingo',
    location: const OfferLocation(lat: 18.4, lng: -69.9),
    payment: const OfferPayment(amount: 1000, currency: 'DOP', period: 'total'),
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

class _ControllerSetup {
  const _ControllerSetup({required this.container, required this.repository});

  final ProviderContainer container;
  final _FakeOffersRepository repository;

  OffersState get state => container.read(offersControllerProvider);

  OffersController get notifier =>
      container.read(offersControllerProvider.notifier);
}

class _FakeOffersRepository implements OffersRepository {
  _FakeOffersRepository({required this.jobTypes, required this.offers});

  final List<JobType> jobTypes;
  final List<Offer> offers;
  final jobTypeCompleters = Queue<Completer<List<JobType>>>();
  final offerCompleters = Queue<Completer<List<Offer>>>();
  final offerCalls = <_OfferCall>[];
  Object? jobTypesError;
  Object? offersError;
  int jobTypeCalls = 0;

  @override
  Future<List<JobType>> getJobTypes() async {
    jobTypeCalls++;
    if (jobTypesError != null) {
      throw jobTypesError!;
    }

    if (jobTypeCompleters.isNotEmpty) {
      return jobTypeCompleters.removeFirst().future;
    }

    return jobTypes;
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    offerCalls.add(
      _OfferCall(jobTypeKey: jobTypeKey, contractType: contractType),
    );

    if (offersError != null) {
      throw offersError!;
    }

    if (offerCompleters.isNotEmpty) {
      return offerCompleters.removeFirst().future;
    }

    return offers;
  }

  @override
  Future<Offer> getOfferById(String id) async {
    return offers.first;
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) async {
    return const ApplyOfferResult(id: 'application-id', status: 'applied');
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

  @override
  Future<List<Offer>> getMyOffers() async {
    return const [];
  }
}

class _OfferCall {
  const _OfferCall({this.jobTypeKey, this.contractType});

  final String? jobTypeKey;
  final String? contractType;

  @override
  bool operator ==(Object other) {
    return other is _OfferCall &&
        other.jobTypeKey == jobTypeKey &&
        other.contractType == contractType;
  }

  @override
  int get hashCode => Object.hash(jobTypeKey, contractType);

  @override
  String toString() {
    return 'OfferCall(jobTypeKey: $jobTypeKey, contractType: $contractType)';
  }
}
