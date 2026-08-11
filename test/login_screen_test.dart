import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/core/widgets/ocupa2_logo.dart';
import 'package:ocupa2/features/auth/data/providers/auth_data_providers.dart';
import 'package:ocupa2/features/auth/domain/entities/auth_session_result.dart';
import 'package:ocupa2/features/auth/domain/repositories/auth_repository.dart';
import 'package:ocupa2/features/auth/presentation/pages/login_screen.dart';
import 'package:ocupa2/features/auth/presentation/widgets/login_form.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  testWidgets('Render de la pantalla', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(LoginForm), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('Logo Ocupa2 visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.byType(Ocupa2Logo), findsOneWidget);
    expect(find.text('Ocupa2'), findsOneWidget);
  });

  testWidgets('Encabezado centrado', (tester) async {
    tester.view.physicalSize = const Size(390, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    final logoCenter = tester.getCenter(
      find.byKey(const Key('loginLogoHeader')),
    );

    expect((logoCenter.dx - 195).abs(), lessThan(1));
  });

  testWidgets('Campo correo visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.widgetWithText(TextFormField, 'Correo'), findsOneWidget);
  });

  testWidgets('Campo contraseña visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
  });

  testWidgets('Correo requerido', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    await _submit(tester);

    expect(find.text('Correo requerido'), findsOneWidget);
  });

  testWidgets('Correo inválido', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    await tester.enterText(find.widgetWithText(TextFormField, 'Correo'), 'bad');
    await _submit(tester);

    expect(find.text('Correo inválido'), findsOneWidget);
  });

  testWidgets('Contraseña requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo'),
      'user@example.com',
    );
    await _submit(tester);

    expect(find.text('Contraseña requerida'), findsOneWidget);
  });

  testWidgets('Contraseña con solo espacios inválida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      '   ',
    );
    await _submit(tester);

    expect(
      find.text('La contraseña no puede contener solo espacios'),
      findsOneWidget,
    );
  });

  testWidgets('El correo se envía con trim', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));

    await _fillValidCredentials(
      tester,
      email: '  user@example.com  ',
      password: 'secret',
    );
    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.loginCalls.single.email, 'user@example.com');
  });

  testWidgets('La contraseña se envía sin trim', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));

    await _fillValidCredentials(
      tester,
      email: 'user@example.com',
      password: '  secret  ',
    );
    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.loginCalls.single.password, '  secret  ');
  });

  testWidgets('Mostrar/ocultar contraseña', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    EditableText passwordEditableText() {
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      return tester.widget<EditableText>(
        find.descendant(of: passwordField, matching: find.byType(EditableText)),
      );
    }

    expect(passwordEditableText().obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();

    expect(passwordEditableText().obscureText, isFalse);
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
  });

  testWidgets('Botón deshabilitado durante loading', (tester) async {
    final repository = _FakeAuthRepository();
    final completer = Completer<AuthSessionResult>();
    repository.loginCompleters.add(completer);
    await tester.pumpWidget(_testApp(repository));

    await _fillValidCredentials(tester);
    await _submit(tester);
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    completer.complete(_result());
    await tester.pumpAndSettle();
  });

  testWidgets('Error del controller se muestra', (tester) async {
    final repository = _FakeAuthRepository();
    repository.loginError = const ApiException(
      message: 'Correo o clave incorrectos',
    );
    await tester.pumpWidget(_testApp(repository));

    await _fillValidCredentials(tester);
    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Correo o clave incorrectos'), findsOneWidget);
  });

  testWidgets('Los datos se conservan tras error', (tester) async {
    final repository = _FakeAuthRepository();
    repository.loginError = const ApiException(message: 'Fallo de login');
    await tester.pumpWidget(_testApp(repository));

    await _fillValidCredentials(
      tester,
      email: 'ana@example.com',
      password: 'secret',
    );
    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('secret'), findsOneWidget);
  });

  testWidgets('Submit exitoso no navega manualmente', (tester) async {
    final observer = _CountingNavigatorObserver();
    await tester.pumpWidget(
      _testApp(_FakeAuthRepository(), observer: observer),
    );

    await _fillValidCredentials(tester);
    final pushesBeforeSubmit = observer.pushes;
    await _submit(tester);
    await tester.pumpAndSettle();

    expect(observer.pushes, pushesBeforeSubmit);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Callback de olvidaste tu contraseña', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _testApp(_FakeAuthRepository(), onForgotPassword: () => calls++),
    );

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('Callback de registrate', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _testApp(_FakeAuthRepository(), onRegister: () => calls++),
    );

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('No overflow en pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Funciona con teclado visible y scroll', (tester) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await tester.ensureVisible(find.text('Entrar'));

    expect(find.text('Entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(
  _FakeAuthRepository repository, {
  NavigatorObserver? observer,
  VoidCallback? onForgotPassword,
  VoidCallback? onRegister,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      navigatorObservers: [?observer],
      home: LoginScreen(
        onForgotPassword: onForgotPassword,
        onRegister: onRegister,
      ),
    ),
  );
}

Future<void> _fillValidCredentials(
  WidgetTester tester, {
  String email = 'user@example.com',
  String password = 'secret',
}) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Correo'), email);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Contraseña'),
    password,
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Entrar'));
  await tester.tap(find.text('Entrar'));
  await tester.pump();
}

AuthSessionResult _result({bool profileCompleted = true}) {
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

class _FakeAuthRepository implements AuthRepository {
  final loginCompleters = Queue<Completer<AuthSessionResult>>();
  final loginCalls = <_LoginCall>[];
  Object? loginError;

  @override
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSessionResult> login({
    required String email,
    required String password,
  }) async {
    loginCalls.add(_LoginCall(email: email, password: password));
    if (loginError != null) {
      throw loginError!;
    }

    if (loginCompleters.isNotEmpty) {
      return loginCompleters.removeFirst().future;
    }

    return _result();
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) {
    throw UnimplementedError();
  }
}

class _LoginCall {
  const _LoginCall({required this.email, required this.password});

  final String email;
  final String password;
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<bool> hasAccessToken() async => false;

  @override
  Future<void> deleteAccessToken() async {}

  @override
  Future<void> clearSession() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Profile> getProfile() async => _result().user;

  @override
  Future<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
    String? email,
    String? referralMatricula,
  }) async {
    return _result().user;
  }
}

class _CountingNavigatorObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}
