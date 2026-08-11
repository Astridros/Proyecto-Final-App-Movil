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
import 'package:ocupa2/features/profile/domain/entities/profile.dart';

// Yeison Familia - pruebas del modulo Inicio.
// Inicio es el slider de bienvenida (InitialScreen); desde ahi se entra al
// Panel, que trae el saludo y los accesos al resto de modulos.
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

    testWidgets('Muestra los accesos a los demas modulos', (tester) async {
      await tester.pumpWidget(_panelApp(session: _sessionWith()));
      await tester.pumpAndSettle();

      expect(find.byType(QuickAccessCard), findsNWidgets(7));
      expect(find.text('Explorar ofertas'), findsOneWidget);
      expect(find.text('Mapa de ofertas'), findsOneWidget);
      expect(find.text('Publicar oferta'), findsOneWidget);
      expect(find.text('Mis ofertas publicadas'), findsOneWidget);
      expect(find.text('Acerca de'), findsOneWidget);
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
      // "Acerca de" tambien vive como QuickAccessCard en el panel, detras del
      // drawer, asi que aparece dos veces mientras el menu esta abierto.
      expect(find.text('Acerca de'), findsNWidgets(2));
      expect(find.text('Cerrar sesión'), findsOneWidget);
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

Widget _panelApp({required AuthSessionState session}) {
  return ProviderScope(
    overrides: [
      authSessionControllerProvider.overrideWith(
        () => _FakeAuthSessionController(session),
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
