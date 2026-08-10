import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ocupa2/app/router/route_names.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_state.dart';
import 'package:ocupa2/features/home/presentation/screens/initial_screen.dart';
import 'package:ocupa2/features/home/presentation/screens/panel_screen.dart';
import 'package:ocupa2/features/home/presentation/widgets/main_drawer.dart';
import 'package:ocupa2/features/home/presentation/widgets/quick_access_card.dart';
import 'package:ocupa2/features/home/presentation/widgets/welcome_slider.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/constants/contract_types.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/create_offer_request.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';

// Yeison Familia - pruebas del modulo Inicio.
// Inicio es el slider de bienvenida (InitialScreen); desde ahi se entra al
// Panel, que trae el saludo, los accesos y la vista previa de ofertas.
void main() {
  group('InitialScreen', () {
    testWidgets('Muestra la primera lamina del slider', (tester) async {
      await tester.pumpWidget(_initialApp());
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeSlider), findsOneWidget);
      expect(find.text('Encuentra tu próximo trabajo'), findsOneWidget);
    });

    testWidgets('No tiene menu lateral ni accesos a modulos', (tester) async {
      await tester.pumpWidget(_initialApp());
      await tester.pumpAndSettle();

      expect(find.byType(MainDrawer), findsNothing);
      expect(find.byType(QuickAccessCard), findsNothing);
    });

    testWidgets('El boton Entrar navega al panel', (tester) async {
      await tester.pumpWidget(_initialApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(PanelScreen), findsOneWidget);
    });

    testWidgets('El slider no avanza solo si el sistema reduce animaciones', (
      tester,
    ) async {
      await tester.pumpWidget(_initialApp());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Encuentra tu próximo trabajo'), findsOneWidget);
    });

    testWidgets('El slider se puede deslizar con el dedo', (tester) async {
      await tester.pumpWidget(_initialApp());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Publica lo que necesitas'), findsOneWidget);
    });
  });

  group('PanelScreen', () {
    testWidgets('Saluda con el nombre del usuario', (tester) async {
      await tester.pumpWidget(
        _panelApp(session: _sessionWith(nombre: 'Yeison Familia')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hola, Yeison'), findsOneWidget);
    });

    testWidgets('Saluda sin nombre cuando el perfil aun no lo tiene', (
      tester,
    ) async {
      await tester.pumpWidget(_panelApp(session: _sessionWith()));
      await tester.pumpAndSettle();

      expect(find.text('Hola'), findsOneWidget);
    });

    testWidgets('No queda texto de andamiaje en la pantalla', (tester) async {
      await tester.pumpWidget(_panelApp(session: _sessionWith()));
      await tester.pumpAndSettle();

      expect(find.text('Base provisional'), findsNothing);
      expect(
        find.text('No se están consumiendo endpoints en esta etapa.'),
        findsNothing,
      );
    });

    testWidgets('La barra inferior da acceso al resto de los modulos', (
      tester,
    ) async {
      await tester.pumpWidget(_panelApp(session: _sessionWith()));
      await tester.pumpAndSettle();

      expect(find.text('Explorar ofertas'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Publicar'), findsOneWidget);
      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Noticias'), findsOneWidget);
    });

    testWidgets('El menu lateral conserva las opciones de sesion y Acerca de', (
      tester,
    ) async {
      await tester.pumpWidget(
        _panelApp(
          session: _sessionWith(nombre: 'Yeison', email: 'yeison@itla.edu.do'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Abrir menú'));
      await tester.pumpAndSettle();

      expect(find.byType(MainDrawer), findsOneWidget);
      expect(find.text('yeison@itla.edu.do'), findsOneWidget);
      expect(find.text('Mi perfil'), findsOneWidget);
      expect(find.text('Mis pagos'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Acerca de'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('Muestra las ofertas recientes de Explorar ofertas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _panelApp(
          session: _sessionWith(),
          offersRepository: _FakeOffersRepository(offers: [_offer()]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ofertas recomendadas'), findsOneWidget);
      expect(find.text('Chofer'), findsOneWidget);
    });

    testWidgets('El vacio de ofertas no bloquea el resto del panel', (
      tester,
    ) async {
      await tester.pumpWidget(
        _panelApp(
          session: _sessionWith(),
          offersRepository: _FakeOffersRepository(offers: const []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todavía no hay ofertas activas.'), findsOneWidget);
      expect(find.text('Publicar'), findsOneWidget);
    });
  });
}

// InitialScreen navega con goNamed, que necesita un GoRouter real en el
// arbol. Se arma uno minimo con solo las dos rutas que la prueba necesita, en
// vez de levantar el router completo de la app.
Widget _initialApp() {
  final router = GoRouter(
    initialLocation: RouteNames.initialPath,
    routes: [
      GoRoute(
        path: RouteNames.initialPath,
        name: RouteNames.initial,
        builder: (context, state) => const InitialScreen(),
      ),
      GoRoute(
        path: RouteNames.panelPath,
        name: RouteNames.panel,
        builder: (context, state) => const PanelScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authSessionControllerProvider.overrideWith(
        () => _FakeAuthSessionController(_sessionWith()),
      ),
      offersRepositoryProvider.overrideWithValue(_FakeOffersRepository()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
      // Se reducen animaciones para que el slider no dispare su temporizador
      // y no interfiera con pumpAndSettle.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        );
      },
    ),
  );
}

Widget _panelApp({
  required AuthSessionState session,
  OffersRepository? offersRepository,
}) {
  return ProviderScope(
    overrides: [
      authSessionControllerProvider.overrideWith(
        () => _FakeAuthSessionController(session),
      ),
      offersRepositoryProvider.overrideWithValue(
        offersRepository ?? _FakeOffersRepository(),
      ),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const PanelScreen()),
  );
}

AuthSessionState _sessionWith({String? nombre, String? email}) {
  return AuthSessionState(
    isRestoring: false,
    isLoggingOut: false,
    isAuthenticated: true,
    profile: Profile(
      id: 'user-1',
      email: email ?? 'estudiante@itla.edu.do',
      profileCompleted: true,
      nombre: nombre,
    ),
    error: null,
    hasCheckedSession: true,
  );
}

class _FakeAuthSessionController extends AuthSessionController {
  _FakeAuthSessionController(this._state);

  final AuthSessionState _state;

  @override
  AuthSessionState build() => _state;
}

Offer _offer() {
  return Offer(
    id: 'offer-id',
    jobTypeKey: 'chofer',
    jobTypeName: 'Chofer',
    contractType: ContractTypes.temporal,
    description: 'Se necesita chofer con licencia vigente.',
    address: 'Santo Domingo',
    location: const OfferLocation(lat: 18.4861, lng: -69.9312),
    payment: const OfferPayment(amount: 25000, currency: 'DOP', period: 'total'),
    photo: '',
    customAnswers: const {},
    questions: const [],
    status: 'published',
    applicantsCount: 0,
    likesCount: 0,
    createdAt: DateTime(2026, 7, 9),
    updatedAt: DateTime(2026, 7, 9),
    isIdentityRevealed: false,
    likedByMe: false,
  );
}

// Solo implementa lo que el panel usa (getOffers). El resto de la interfaz
// no aplica a esta vista previa, asi que revienta a proposito si algo llega
// a llamarlo por error.
class _FakeOffersRepository implements OffersRepository {
  _FakeOffersRepository({this.offers = const []});

  final List<Offer> offers;

  @override
  Future<List<Offer>> getOffers({String? jobTypeKey, String? contractType}) {
    return Future.value(offers);
  }

  @override
  Future<List<JobType>> getJobTypes() => Future.value(const []);

  @override
  Future<Offer> getOfferById(String id) => throw UnimplementedError();

  @override
  Future<Offer> createOffer(CreateOfferRequest request) =>
      throw UnimplementedError();

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) => throw UnimplementedError();

  @override
  Future<OfferLikeResult> likeOffer(String offerId) =>
      throw UnimplementedError();

  @override
  Future<OfferLikeResult> unlikeOffer(String offerId) =>
      throw UnimplementedError();

  @override
  Future<List<Offer>> getMyLikedOffers() => throw UnimplementedError();
}
