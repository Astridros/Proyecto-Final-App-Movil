import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ocupa2/app/app.dart';
import 'package:ocupa2/app/router/route_names.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/core/widgets/app_button.dart';
import 'package:ocupa2/core/widgets/app_text_field.dart';
import 'package:ocupa2/features/applications/data/providers/applications_data_providers.dart';
import 'package:ocupa2/features/applications/domain/entities/application.dart';
import 'package:ocupa2/features/applications/domain/repositories/applications_repository.dart';
import 'package:ocupa2/features/auth/data/providers/auth_data_providers.dart';
import 'package:ocupa2/features/auth/domain/entities/auth_session_result.dart';
import 'package:ocupa2/features/auth/domain/repositories/auth_repository.dart';
import 'package:ocupa2/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:ocupa2/features/auth/presentation/pages/login_screen.dart';
import 'package:ocupa2/features/auth/presentation/pages/register_screen.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/change_password/data/providers/change_password_data_providers.dart';
import 'package:ocupa2/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:ocupa2/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/pages/offer_detail_screen.dart';
import 'package:ocupa2/features/offers/presentation/pages/offers_screen.dart';
import 'package:ocupa2/features/offers/presentation/widgets/offer_card.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';
import 'package:ocupa2/features/profile/presentation/pages/complete_profile_screen.dart';

void main() {
  testWidgets('App se construye correctamente', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('/login muestra LoginScreen real', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Acceso a Ocupa2'), findsNothing);
  });

  testWidgets('Login abre Registro', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('Login abre Recuperar contraseña', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('Recuperar contraseña'), findsOneWidget);
  });

  testWidgets('Registro vuelve a Login', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.tap(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });

  testWidgets('Recuperación vuelve a Login', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ForgotPasswordScreen), findsNothing);
  });

  testWidgets('Usuario sin token no accede a rutas privadas', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(LoginScreen)),
    ).go(RouteNames.offersPath);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OffersScreen), findsNothing);
  });

  testWidgets('Sin token redirige offer detail a login', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(LoginScreen)),
    ).go('/offers/offer-id');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OfferDetailScreen), findsNothing);
  });

  testWidgets('Usuario sin token no accede a change-password', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(LoginScreen)),
    ).go(RouteNames.changePasswordPath);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('Usuario sin token puede abrir las tres rutas públicas', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.byType(LoginScreen)));
    expect(find.byType(LoginScreen), findsOneWidget);

    router.go(RouteNames.registerPath);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    router.go(RouteNames.forgotPasswordPath);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    router.go(RouteNames.loginPath);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets(
    'Usuario autenticado con perfil incompleto va a complete-profile',
    (tester) async {
      final profileRepository = _FakeProfileRepository();
      await tester.pumpWidget(
        _testApp(profileRepository: profileRepository, hasToken: true),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompleteProfileScreen), findsOneWidget);
      expect(profileRepository.getProfileCalls, 1);
    },
  );

  testWidgets('Perfil incompleto no puede volver a rutas públicas', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(CompleteProfileScreen)),
    ).go(RouteNames.loginPath);
    await tester.pumpAndSettle();

    expect(find.byType(CompleteProfileScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Perfil incompleto no puede abrir change-password', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(CompleteProfileScreen)),
    ).go(RouteNames.changePasswordPath);
    await tester.pumpAndSettle();

    expect(find.byType(CompleteProfileScreen), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('Perfil incompleto no puede abrir detalle de oferta', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(CompleteProfileScreen)),
    ).go('/offers/offer-id');
    await tester.pumpAndSettle();

    expect(find.byType(CompleteProfileScreen), findsOneWidget);
    expect(find.byType(OfferDetailScreen), findsNothing);
  });

  testWidgets(
    'Usuario autenticado con perfil completo entra a ruta principal',
    (tester) async {
      await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
      await tester.pumpAndSettle();

      expect(find.text('Base provisional'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Iniciar sesión'), findsNothing);
    },
  );

  testWidgets('Perfil completo puede acceder a change-password', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.text('Ocupa2')),
    ).go(RouteNames.changePasswordPath);
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsWidgets);
  });

  testWidgets('El botón Cambiar contraseña aparece en InitialScreen', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    expect(find.text('Cambiar contraseña'), findsOneWidget);
  });

  testWidgets('El botón Cerrar sesión aparece en InitialScreen', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('Cancelar no cierra sesión', (tester) async {
    final tokenStorage = _FakeTokenStorage('token');
    await tester.pumpWidget(
      _testApp(
        hasToken: true,
        profileCompleted: true,
        tokenStorage: tokenStorage,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(tokenStorage.clearSessionCalls, 0);
    expect(find.text('Base provisional'), findsOneWidget);
  });

  testWidgets('Confirmar ejecuta logout y muestra LoginScreen', (tester) async {
    final tokenStorage = _FakeTokenStorage('token');
    await tester.pumpWidget(
      _testApp(
        hasToken: true,
        profileCompleted: true,
        tokenStorage: tokenStorage,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión').last);
    await tester.pumpAndSettle();

    expect(tokenStorage.clearSessionCalls, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Usuario cerrado no puede acceder a rutas privadas', (
    tester,
  ) async {
    final tokenStorage = _FakeTokenStorage('token');
    await tester.pumpWidget(
      _testApp(
        hasToken: true,
        profileCompleted: true,
        tokenStorage: tokenStorage,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión').last);
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(LoginScreen)),
    ).go(RouteNames.offersPath);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OffersScreen), findsNothing);
  });

  testWidgets('El botón Cambiar contraseña navega correctamente', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cambiar contraseña'));
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  testWidgets('El botón de regreso funciona', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cambiar contraseña'));
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.text('Base provisional'), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('Un cambio exitoso mantiene la sesión activa', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cambiar contraseña'));
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nueva contraseña'),
      'NuevaClave123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar nueva contraseña'),
      'NuevaClave123',
    );
    await tester.tap(find.text('Cambiar contraseña').last);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ChangePasswordScreen)),
    );
    expect(
      container.read(authSessionControllerProvider).isAuthenticated,
      isTrue,
    );
    expect(find.text('Contraseña actualizada correctamente.'), findsOneWidget);
  });

  testWidgets(
    'Perfil completo no puede volver a login, registro ni recuperación',
    (tester) async {
      await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
      await tester.pumpAndSettle();

      final router = GoRouter.of(tester.element(find.text('Ocupa2')));

      router.go(RouteNames.loginPath);
      await tester.pumpAndSettle();
      expect(find.text('Base provisional'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      router.go(RouteNames.registerPath);
      await tester.pumpAndSettle();
      expect(find.text('Base provisional'), findsOneWidget);
      expect(find.byType(RegisterScreen), findsNothing);

      router.go(RouteNames.forgotPasswordPath);
      await tester.pumpAndSettle();
      expect(find.text('Base provisional'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    },
  );

  testWidgets(
    'Login exitoso con profileCompleted false redirige a completar perfil',
    (tester) async {
      await tester.pumpWidget(
        _testApp(
          authRepository: _FakeAuthRepository(
            loginResult: _sessionResult(profileCompleted: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _fillLogin(tester);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(CompleteProfileScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Login exitoso con profileCompleted true redirige al flujo principal',
    (tester) async {
      await tester.pumpWidget(
        _testApp(
          authRepository: _FakeAuthRepository(
            loginResult: _sessionResult(profileCompleted: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _fillLogin(tester);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Base provisional'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );

  testWidgets('Registro exitoso respeta profileCompleted', (tester) async {
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(
          registerResult: _sessionResult(profileCompleted: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    await _fillRegister(tester);
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.byType(CompleteProfileScreen), findsOneWidget);
  });

  testWidgets('No existen loops de redirección', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.text('Ocupa2'))).go(RouteNames.loginPath);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Base provisional'), findsOneWidget);
  });

  testWidgets('No hay loops al abrir change-password', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.text('Ocupa2')),
    ).go(RouteNames.changePasswordPath);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  testWidgets('LoginPlaceholderScreen ya no se utiliza', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Acceso a Ocupa2'), findsNothing);
    expect(
      find.text('Vista temporal para validar campos y botones.'),
      findsNothing,
    );
  });

  testWidgets('Navegación no acumula múltiples pantallas Login', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.tap(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Usuario autenticado ve loading mientras carga GET me', (
    tester,
  ) async {
    final profileRepository = _FakeProfileRepository()
      ..profileCompleter = Completer<Profile>();

    await tester.pumpWidget(
      _testApp(profileRepository: profileRepository, hasToken: true),
    );
    await tester.pump();

    expect(find.text('Validando sesión...'), findsOneWidget);
    expect(profileRepository.getProfileCalls, 1);
  });

  testWidgets('Error de GET me no bloquea el router indefinidamente', (
    tester,
  ) async {
    final profileRepository = _FakeProfileRepository()
      ..profileError = const ApiException(message: 'No autorizado');

    await tester.pumpWidget(
      _testApp(profileRepository: profileRepository, hasToken: true),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Validando sesión...'), findsNothing);
  });

  testWidgets('La ruta de ofertas abre OffersScreen para perfil completo', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.text('Ocupa2'))).go(RouteNames.offersPath);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(OffersScreen), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
  });

  testWidgets('/offers/:id muestra OfferDetailScreen', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.text('Ocupa2'))).go('/offers/offer-id');
    await tester.pumpAndSettle();

    expect(find.byType(OfferDetailScreen), findsOneWidget);
    expect(find.text('Detalle de oferta'), findsOneWidget);
  });

  testWidgets('OfferCard navega pasando solo el id', (tester) async {
    final offersRepository = _FakeOffersRepository();
    await tester.pumpWidget(
      _testApp(
        hasToken: true,
        profileCompleted: true,
        offersRepository: offersRepository,
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.text('Ocupa2'))).go(RouteNames.offersPath);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OfferCard));
    await tester.pumpAndSettle();

    expect(find.byType(OfferDetailScreen), findsOneWidget);
    expect(offersRepository.lastDetailId, 'offer-id');
  });

  testWidgets('Boton volver del detalle regresa a ofertas', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.text('Ocupa2'))).go(RouteNames.offersPath);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OfferCard));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Volver'));
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.byType(OffersScreen), findsOneWidget);
    expect(find.byType(OfferDetailScreen), findsNothing);
  });

  testWidgets('OffersScreen carga datos del repositorio', (tester) async {
    await tester.pumpWidget(_testApp(hasToken: true, profileCompleted: true));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.text('Ocupa2'))).go(RouteNames.offersPath);
    await tester.pumpAndSettle();

    expect(find.text('Chofer'), findsWidgets);
    expect(
      find.text('Se necesita chofer con disponibilidad inmediata.'),
      findsOneWidget,
    );
  });

  testWidgets('AppButton outlined se construye correctamente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton.outlined(
            label: 'Volver',
            icon: Icons.arrow_back_rounded,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
  });

  testWidgets('AppButton muestra loading correctamente', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppButton(label: 'Guardar', isLoading: true)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });

  testWidgets('AppTextField muestra error de validación', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              label: 'Correo',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es obligatorio';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
  });
}

Widget _testApp({
  _FakeAuthRepository? authRepository,
  _FakeProfileRepository? profileRepository,
  _FakeOffersRepository? offersRepository,
  _FakeTokenStorage? tokenStorage,
  bool hasToken = false,
  bool profileCompleted = false,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        authRepository ?? _FakeAuthRepository(),
      ),
      tokenStorageProvider.overrideWithValue(
        tokenStorage ?? _FakeTokenStorage(hasToken ? 'token' : null),
      ),
      offersRepositoryProvider.overrideWithValue(
        offersRepository ?? _FakeOffersRepository(),
      ),
      applicationsRepositoryProvider.overrideWithValue(
        _FakeApplicationsRepository(),
      ),
      changePasswordRepositoryProvider.overrideWithValue(
        _FakeChangePasswordRepository(),
      ),
      profileRepositoryProvider.overrideWithValue(
        profileRepository ??
            _FakeProfileRepository(profileCompleted: profileCompleted),
      ),
    ],
    child: const Ocupa2App(),
  );
}

Future<void> _fillLogin(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Correo'),
    'user@example.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Contraseña'),
    'secret123',
  );
}

Future<void> _fillRegister(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Ana');
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Apellido'),
    'Perez',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Correo'),
    'user@example.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Matrícula de referido'),
    '12345678',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Contraseña'),
    'secret123',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmar contraseña'),
    'secret123',
  );
  await tester.ensureVisible(find.text('Registrarme'));
}

AuthSessionResult _sessionResult({required bool profileCompleted}) {
  return AuthSessionResult(
    token: 'token',
    tokenType: 'Bearer',
    user: Profile(
      id: 'profile-id',
      email: 'user@example.com',
      firstName: 'Ana',
      lastName: 'Perez',
      profileCompleted: profileCompleted,
    ),
  );
}

JobType _jobType() {
  return JobType(
    id: 'chofer-id',
    key: 'chofer',
    name: 'Chofer',
    active: true,
    customFields: const [],
    createdAt: DateTime(2026),
  );
}

Offer _offer() {
  return Offer(
    id: 'offer-id',
    jobTypeKey: 'chofer',
    jobTypeName: 'Chofer',
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
    likesCount: 0,
    createdAt: DateTime(2026, 7, 9),
    updatedAt: DateTime(2026, 7, 9),
    isIdentityRevealed: false,
    likedByMe: false,
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    AuthSessionResult? loginResult,
    AuthSessionResult? registerResult,
  }) : loginResult = loginResult ?? _sessionResult(profileCompleted: true),
       registerResult =
           registerResult ?? _sessionResult(profileCompleted: true);

  final AuthSessionResult loginResult;
  final AuthSessionResult registerResult;

  @override
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    return registerResult;
  }

  @override
  Future<AuthSessionResult> login({
    required String email,
    required String password,
  }) async {
    return loginResult;
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {}
}

class _FakeChangePasswordRepository implements ChangePasswordRepository {
  final passwords = <String>[];

  @override
  Future<void> changePassword({required String password}) async {
    passwords.add(password);
  }
}

class _FakeOffersRepository implements OffersRepository {
  String? lastDetailId;

  @override
  Future<List<JobType>> getJobTypes() async {
    return [_jobType()];
  }

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    return [_offer()];
  }

  @override
  Future<Offer> getOfferById(String id) async {
    lastDetailId = id;
    return _offer();
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) async {
    return const ApplyOfferResult(id: 'application-id', status: 'applied');
  }
}

class _FakeApplicationsRepository implements ApplicationsRepository {
  @override
  Future<List<Application>> getMyApplications() async {
    return const [];
  }
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({bool profileCompleted = false})
    : profile = Profile(
        id: 'profile-id',
        email: 'astrid@example.com',
        firstName: 'Astrid',
        lastName: 'Diaz',
        nombre: 'Astrid Diaz',
        referralMatricula: 'MAT-001',
        role: 'worker',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        lastLoginAt: DateTime(2026),
        birthDate: DateTime.utc(1997, 5, 12),
        cedula: '00112345678',
        gender: 'femenino',
        profileCompleted: profileCompleted,
      );

  Profile profile;
  Completer<Profile>? profileCompleter;
  Object? profileError;
  int getProfileCalls = 0;

  @override
  Future<Profile> getProfile() async {
    getProfileCalls++;
    if (profileError != null) {
      throw profileError!;
    }

    final completer = profileCompleter;
    if (completer != null) {
      return completer.future;
    }

    return profile;
  }

  @override
  Future<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  }) async {
    profile = Profile(
      id: profile.id,
      email: profile.email,
      firstName: firstName,
      lastName: lastName,
      nombre: '$firstName $lastName',
      referralMatricula: profile.referralMatricula,
      role: profile.role,
      createdAt: profile.createdAt,
      updatedAt: DateTime(2026, 7, 28),
      lastLoginAt: profile.lastLoginAt,
      birthDate: birthDate,
      cedula: cedula,
      gender: gender,
      profileCompleted: true,
    );

    return profile;
  }
}

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage(this._token);

  String? _token;
  int clearSessionCalls = 0;

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> readAccessToken() async {
    final normalized = _token?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  @override
  Future<bool> hasAccessToken() async {
    return (await readAccessToken()) != null;
  }

  @override
  Future<void> deleteAccessToken() async {
    _token = null;
  }

  @override
  Future<void> clearSession() async {
    clearSessionCalls++;
    _token = null;
  }
}
