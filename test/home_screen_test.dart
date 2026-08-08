import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_state.dart';
import 'package:ocupa2/features/home/presentation/screens/initial_screen.dart';
import 'package:ocupa2/features/home/presentation/widgets/main_drawer.dart';
import 'package:ocupa2/features/home/presentation/widgets/quick_access_card.dart';
import 'package:ocupa2/features/home/presentation/widgets/welcome_slider.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';

// Yeison Familia - pruebas del modulo Inicio.
void main() {
  testWidgets('Saluda con el nombre del usuario', (tester) async {
    await tester.pumpWidget(_testApp(_sessionWith(nombre: 'Yeison Familia')));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Yeison'), findsOneWidget);
  });

  testWidgets('Saluda sin nombre cuando el perfil aun no lo tiene', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(_sessionWith()));
    await tester.pumpAndSettle();

    expect(find.text('Hola'), findsOneWidget);
  });

  testWidgets('Muestra la primera lamina del slider', (tester) async {
    await tester.pumpWidget(_testApp(_sessionWith()));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeSlider), findsOneWidget);
    expect(find.text('Bienvenido a Ocupa2'), findsOneWidget);
  });

  testWidgets('No queda texto de andamiaje en la pantalla', (tester) async {
    await tester.pumpWidget(_testApp(_sessionWith()));
    await tester.pumpAndSettle();

    expect(find.text('Base provisional'), findsNothing);
    expect(
      find.text('No se están consumiendo endpoints en esta etapa.'),
      findsNothing,
    );
  });

  testWidgets('Muestra los accesos rapidos a los modulos', (tester) async {
    await tester.pumpWidget(_testApp(_sessionWith()));
    await tester.pumpAndSettle();

    expect(find.byType(QuickAccessCard), findsNWidgets(5));
    expect(find.text('Explorar ofertas'), findsOneWidget);
    expect(find.text('Mapa de ofertas'), findsOneWidget);
    expect(find.text('Noticias'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
    expect(find.text('Acerca de'), findsOneWidget);
  });

  testWidgets('El menu lateral conserva las opciones de sesion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(_sessionWith(nombre: 'Yeison', email: 'yeison@itla.edu.do')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Abrir menú'));
    await tester.pumpAndSettle();

    expect(find.byType(MainDrawer), findsOneWidget);
    expect(find.text('yeison@itla.edu.do'), findsOneWidget);
    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('El slider no avanza solo si el sistema reduce animaciones', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(_sessionWith()));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Bienvenido a Ocupa2'), findsOneWidget);
  });

  testWidgets('El slider avanza solo a la siguiente lamina', (tester) async {
    await tester.pumpWidget(
      _testApp(_sessionWith(), disableAnimations: false),
    );
    await tester.pump();

    expect(find.text('Bienvenido a Ocupa2'), findsOneWidget);

    // Se dispara el temporizador y luego se deja terminar la animacion.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Encuentra tu próximo trabajo'), findsOneWidget);

    // Se desmonta la pantalla para que el temporizador se cancele y no quede
    // pendiente al cerrar la prueba.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('El slider se puede deslizar con el dedo', (tester) async {
    await tester.pumpWidget(_testApp(_sessionWith()));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Encuentra tu próximo trabajo'), findsOneWidget);
  });
}

// Por defecto las pruebas corren con animaciones reducidas: asi el slider no
// arranca su temporizador y no interfiere con pumpAndSettle.
Widget _testApp(AuthSessionState state, {bool disableAnimations = true}) {
  return ProviderScope(
    overrides: [
      authSessionControllerProvider.overrideWith(
        () => _FakeAuthSessionController(state),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: const InitialScreen(),
          );
        },
      ),
    ),
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
