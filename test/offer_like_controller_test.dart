import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/providers/offer_like_providers.dart';

void main() {
  test('Estado inicial por offerId', () {
    final setup = _setup();

    final state = setup.container.read(offerLikeControllerProvider('offer-a'));

    expect(state.isSubmitting, isFalse);
    expect(state.liked, isFalse);
    expect(state.likesCount, 0);
    expect(state.hasLocalInteraction, isFalse);
    expect(state.error, isNull);
  });

  test('syncFromOffer inicializa liked y likesCount', () {
    final setup = _setup();

    setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .syncFromOffer(likedByMe: true, likesCount: 7);

    final state = setup.container.read(offerLikeControllerProvider('offer-a'));
    expect(state.liked, isTrue);
    expect(state.likesCount, 7);
  });

  test('liked false llama POST', () async {
    final setup = _setup(
      likeResult: const OfferLikeResult(liked: true, likesCount: 1),
    );

    await setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();

    expect(setup.repository.likeCalls, ['offer-a']);
    expect(setup.repository.unlikeCalls, isEmpty);
  });

  test('liked true llama DELETE', () async {
    final setup = _setup(
      unlikeResult: const OfferLikeResult(liked: false, likesCount: 3),
    );
    setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .syncFromOffer(likedByMe: true, likesCount: 4);

    await setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();

    expect(setup.repository.unlikeCalls, ['offer-a']);
    expect(setup.repository.likeCalls, isEmpty);
  });

  test('Exito actualiza liked y likesCount', () async {
    final setup = _setup(
      likeResult: const OfferLikeResult(liked: true, likesCount: 5),
    );

    final result = await setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();

    final state = setup.container.read(offerLikeControllerProvider('offer-a'));
    expect(result, isTrue);
    expect(state.liked, isTrue);
    expect(state.likesCount, 5);
    expect(state.hasLocalInteraction, isTrue);
  });

  test(
    'Error conserva liked y likesCount anterior y guarda AppException',
    () async {
      final setup = _setup()
        ..repository.likeError = const ApiException(message: 'Fallo like');
      setup.container
          .read(offerLikeControllerProvider('offer-a').notifier)
          .syncFromOffer(likedByMe: false, likesCount: 2);

      final result = await setup.container
          .read(offerLikeControllerProvider('offer-a').notifier)
          .toggleLike();

      final state = setup.container.read(
        offerLikeControllerProvider('offer-a'),
      );
      expect(result, isFalse);
      expect(state.liked, isFalse);
      expect(state.likesCount, 2);
      expect(state.error?.message, 'Fallo like');
    },
  );

  test('Evita doble toque e isSubmitting vuelve a false', () async {
    final completer = Completer<OfferLikeResult>();
    final setup = _setup()..repository.likeCompleter = completer;

    final first = setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();
    final second = setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();

    expect(setup.repository.likeCalls, ['offer-a']);
    expect(
      setup.container.read(offerLikeControllerProvider('offer-a')).isSubmitting,
      isTrue,
    );

    completer.complete(const OfferLikeResult(liked: true, likesCount: 1));
    expect(await Future.wait([first, second]), [true, false]);
    expect(
      setup.container.read(offerLikeControllerProvider('offer-a')).isSubmitting,
      isFalse,
    );
  });

  test('Cada offerId mantiene estado independiente', () async {
    final setup = _setup(
      likeResult: const OfferLikeResult(liked: true, likesCount: 1),
    );

    await setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();

    final a = setup.container.read(offerLikeControllerProvider('offer-a'));
    final b = setup.container.read(offerLikeControllerProvider('offer-b'));
    expect(a.liked, isTrue);
    expect(b.liked, isFalse);
  });

  test('syncFromOffer no pisa interaccion local', () async {
    final setup = _setup(
      likeResult: const OfferLikeResult(liked: true, likesCount: 9),
    );

    await setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .toggleLike();
    setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .syncFromOffer(likedByMe: false, likesCount: 0);

    final state = setup.container.read(offerLikeControllerProvider('offer-a'));
    expect(state.liked, isTrue);
    expect(state.likesCount, 9);
  });

  test('Provider nuevo se inicializa desde backend', () {
    final setup = _setup();

    setup.container
        .read(offerLikeControllerProvider('offer-b').notifier)
        .syncFromOffer(likedByMe: true, likesCount: 4);

    final state = setup.container.read(offerLikeControllerProvider('offer-b'));
    expect(state.liked, isTrue);
    expect(state.likesCount, 4);
  });

  test('likedByMe false cargado desde backend muestra estado no liked', () {
    final setup = _setup();

    setup.container
        .read(offerLikeControllerProvider('offer-a').notifier)
        .syncFromOffer(likedByMe: false, likesCount: -2);

    final state = setup.container.read(offerLikeControllerProvider('offer-a'));
    expect(state.liked, isFalse);
    expect(state.likesCount, 0);
  });

  test('clearError elimina error', () async {
    final setup = _setup()
      ..repository.likeError = const ApiException(message: 'Fallo');
    final notifier = setup.container.read(
      offerLikeControllerProvider('offer-a').notifier,
    );
    await notifier.toggleLike();

    notifier.clearError();

    expect(
      setup.container.read(offerLikeControllerProvider('offer-a')).error,
      isNull,
    );
  });

  test('Repository puede sustituirse con provider override', () {
    final repository = _FakeOffersRepository();
    final container = ProviderContainer(
      overrides: [offersRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(offersRepositoryProvider), same(repository));
  });
}

_Setup _setup({
  OfferLikeResult likeResult = const OfferLikeResult(
    liked: true,
    likesCount: 1,
  ),
  OfferLikeResult unlikeResult = const OfferLikeResult(
    liked: false,
    likesCount: 0,
  ),
}) {
  final repository = _FakeOffersRepository(
    likeResult: likeResult,
    unlikeResult: unlikeResult,
  );
  final container = ProviderContainer(
    overrides: [offersRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return _Setup(container: container, repository: repository);
}

class _Setup {
  const _Setup({required this.container, required this.repository});

  final ProviderContainer container;
  final _FakeOffersRepository repository;
}

class _FakeOffersRepository implements OffersRepository {
  _FakeOffersRepository({
    this.likeResult = const OfferLikeResult(liked: true, likesCount: 1),
    this.unlikeResult = const OfferLikeResult(liked: false, likesCount: 0),
  });

  final OfferLikeResult likeResult;
  final OfferLikeResult unlikeResult;
  final likeCalls = <String>[];
  final unlikeCalls = <String>[];
  Object? likeError;
  Object? unlikeError;
  Completer<OfferLikeResult>? likeCompleter;

  @override
  Future<List<JobType>> getJobTypes() async => const [];

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    return const [];
  }

  @override
  Future<Offer> getOfferById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OfferLikeResult> likeOffer(String offerId) async {
    likeCalls.add(offerId);
    if (likeError != null) {
      throw likeError!;
    }

    return likeCompleter?.future ?? likeResult;
  }

  @override
  Future<OfferLikeResult> unlikeOffer(String offerId) async {
    unlikeCalls.add(offerId);
    if (unlikeError != null) {
      throw unlikeError!;
    }

    return unlikeResult;
  }

  @override
  Future<List<Offer>> getMyLikedOffers() async => const [];
}
