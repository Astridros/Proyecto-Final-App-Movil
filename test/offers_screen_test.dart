import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/widgets/app_empty_state.dart';
import 'package:ocupa2/core/widgets/app_error_view.dart';
import 'package:ocupa2/core/widgets/app_loading.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/pages/offers_screen.dart';
import 'package:ocupa2/features/offers/presentation/providers/offers_presentation_providers.dart';
import 'package:ocupa2/features/offers/presentation/widgets/active_filters_summary.dart';
import 'package:ocupa2/features/offers/presentation/widgets/offer_card.dart';
import 'package:ocupa2/features/offers/presentation/widgets/offers_filter_bar.dart';

void main() {
  testWidgets('muestra loading inicial', (tester) async {
    final repository = _FakeOffersRepository();
    repository.jobTypesCompleter = Completer<List<JobType>>();
    repository.offersCompleter = Completer<List<Offer>>();

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.byType(AppLoading), findsOneWidget);
  });

  testWidgets('muestra error sin ofertas', (tester) async {
    final repository = _FakeOffersRepository(
      jobTypesError: const ApiException(message: 'Fallo controlado'),
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(OffersFilterBar), findsOneWidget);
    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Fallo controlado'), findsOneWidget);
  });

  testWidgets('muestra EmptyState sin ofertas', (tester) async {
    final repository = _FakeOffersRepository(offers: const []);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(OffersFilterBar), findsOneWidget);
    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('muestra lista con varias ofertas', (tester) async {
    final repository = _FakeOffersRepository(
      offers: [
        _offer('uno'),
        _offer('dos', jobTypeName: 'Cocina'),
      ],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Chofer'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Cocina'),
      420,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Cocina'), findsOneWidget);
  });

  testWidgets('RefreshIndicator ejecuta refresh', (tester) async {
    final repository = _FakeOffersRepository(
      offers: [_offer('uno'), _offer('dos')],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, 320));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.jobTypeCalls, 2);
    expect(repository.offerCalls, 2);
  });

  testWidgets('OfferCard recibe callback preparado', (tester) async {
    final repository = _FakeOffersRepository(offers: [_offer('uno')]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    final card = tester.widget<OfferCard>(find.byType(OfferCard));

    expect(card.onTap, isNotNull);
  });

  testWidgets('OffersScreen conecta estado correcto por oferta', (
      tester,
      ) async {
    final repository = _FakeOffersRepository(
      offers: [_offer('uno', likedByMe: true, likesCount: 4)],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('OffersScreen permite alternar like sin recargar lista', (
      tester,
      ) async {
    final repository = _FakeOffersRepository(offers: [_offer('uno')]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.favorite_border_rounded),
    );
    await tester.pumpAndSettle();

    expect(repository.likeCalls, ['uno']);
    expect(repository.offerCalls, 1);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('OffersFilterBar siempre permanece visible', (tester) async {
    final repository = _FakeOffersRepository(offers: const []);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(OffersFilterBar), findsOneWidget);
    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('ActiveFiltersSummary aparece cuando existen filtros', (
      tester,
      ) async {
    final container = ProviderContainer(
      overrides: [
        offersRepositoryProvider.overrideWithValue(
          _FakeOffersRepository(offers: [_offer('uno')]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_testAppWithContainer(container));
    await tester.pumpAndSettle();
    await container
        .read(offersControllerProvider.notifier)
        .changeJobType('chofer');
    await tester.pumpAndSettle();

    expect(find.byType(ActiveFiltersSummary), findsOneWidget);
    expect(find.text('1 filtro activo'), findsOneWidget);
  });

  testWidgets('no existen overflows en pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeOffersRepository(
      offers: [_offer('uno'), _offer('dos')],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(_FakeOffersRepository repository) {
  return ProviderScope(
    overrides: [offersRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light, home: const OffersScreen()),
  );
}

Widget _testAppWithContainer(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: AppTheme.light, home: const OffersScreen()),
  );
}

JobType _jobType(String key) {
  return JobType(
    id: '$key-id',
    key: key,
    name: key == 'chofer' ? 'Chofer' : key,
    active: true,
    customFields: const [],
    createdAt: DateTime(2026),
  );
}

Offer _offer(
    String id, {
      String jobTypeName = 'Chofer',
      bool likedByMe = false,
      int likesCount = 0,
    }) {
  return Offer(
    id: id,
    jobTypeKey: 'chofer',
    jobTypeName: jobTypeName,
    contractType: 'temporal',
    description: 'Se necesita chofer con disponibilidad inmediata.',
    address: 'Santo Domingo, República Dominicana',
    location: const OfferLocation(lat: 18.4861, lng: -69.9312),
    payment: const OfferPayment(
      amount: 35000,
      currency: 'DOP',
      period: 'total',
    ),
    photo: 'string',
    deadline: DateTime(2026, 8, 30),
    customAnswers: const {},
    questions: const [],
    status: 'published',
    applicantsCount: 1,
    likesCount: likesCount,
    createdAt: DateTime(2026, 7, 9),
    updatedAt: DateTime(2026, 7, 9),
    isIdentityRevealed: false,
    likedByMe: likedByMe,
  );
}

class _FakeOffersRepository implements OffersRepository {
  _FakeOffersRepository({
    List<JobType>? jobTypes,
    List<Offer>? offers,
    this.jobTypesError,
  }) : jobTypes = jobTypes ?? [_jobType('chofer')],
        offers = offers ?? [_offer('uno')];

  final List<JobType> jobTypes;
  final List<Offer> offers;
  final Object? jobTypesError;
  Completer<List<JobType>>? jobTypesCompleter;
  Completer<List<Offer>>? offersCompleter;
  final likeCalls = <String>[];
  final unlikeCalls = <String>[];
  int jobTypeCalls = 0;
  int offerCalls = 0;

  @override
  Future<List<JobType>> getJobTypes() {
    jobTypeCalls++;
    if (jobTypesError != null) {
      throw jobTypesError!;
    }

    return jobTypesCompleter?.future ?? Future.value(jobTypes);
  }

  @override
  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType}) {
    offerCalls++;
    return offersCompleter?.future ?? Future.value(offers);
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
    likeCalls.add(offerId);
    return const OfferLikeResult(liked: true, likesCount: 1);
  }

  @override
  Future<OfferLikeResult> unlikeOffer(String offerId) async {
    unlikeCalls.add(offerId);
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
