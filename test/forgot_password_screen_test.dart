import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/auth/data/providers/auth_data_providers.dart';
import 'package:ocupa2/features/auth/domain/entities/auth_session_result.dart';
import 'package:ocupa2/features/auth/domain/repositories/auth_repository.dart';
import 'package:ocupa2/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/auth/presentation/widgets/forgot_password_form.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  testWidgets('Render de pantalla', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.byType(ForgotPasswordForm), findsOneWidget);
    expect(find.text('Recuperar contraseña'), findsOneWidget);
  });

  testWidgets('Campo correo visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.widgetWithText(TextFormField, 'Correo'), findsOneWidget);
  });

  testWidgets('Campo matrícula visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(
      find.widgetWithText(TextFormField, 'Matrícula de referido'),
      findsOneWidget,
    );
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

  testWidgets('Matrícula requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo'),
      'user@example.com',
    );

    await _submit(tester);

    expect(find.text('Matrícula requerida'), findsOneWidget);
  });

  testWidgets('Matrícula no numérica', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidData(tester, referralMatricula: '12AB5678');

    await _submit(tester);

    expect(find.text('Matrícula solo numérica'), findsOneWidget);
  });

  testWidgets('Matrícula con longitud incorrecta', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidData(tester, referralMatricula: '1234567');

    await _submit(tester);

    expect(find.text('Matrícula debe tener 8 dígitos'), findsOneWidget);
  });

  testWidgets('Trim correcto', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));
    await _fillValidData(
      tester,
      email: '  user@example.com  ',
      referralMatricula: '  12345678  ',
    );

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.forgotPasswordCalls.single.email, 'user@example.com');
    expect(repository.forgotPasswordCalls.single.referralMatricula, '12345678');
  });

  testWidgets('Submit llama forgotPassword con los valores correctos', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));
    await _fillValidData(tester);

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(
      repository.forgotPasswordCalls.single,
      const _ForgotPasswordCall(
        email: 'user@example.com',
        referralMatricula: '12345678',
      ),
    );
  });

  testWidgets('Loading deshabilita el botón', (tester) async {
    final repository = _FakeAuthRepository();
    final completer = Completer<void>();
    repository.forgotPasswordCompleters.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await _fillValidData(tester);

    await _submit(tester);
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Evita doble submit', (tester) async {
    final repository = _FakeAuthRepository();
    final completer = Completer<void>();
    repository.forgotPasswordCompleters.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await _fillValidData(tester);

    await _submit(tester);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();

    expect(repository.forgotPasswordCalls, hasLength(1));
    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Error del controller se muestra', (tester) async {
    final repository = _FakeAuthRepository();
    repository.forgotPasswordError = const ApiException(
      message: 'Datos incorrectos',
    );
    await tester.pumpWidget(_testApp(repository));
    await _fillValidData(tester);

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Datos incorrectos'), findsOneWidget);
  });

  testWidgets('Los datos se conservan tras error', (tester) async {
    final repository = _FakeAuthRepository();
    repository.forgotPasswordError = const ApiException(message: 'Fallo');
    await tester.pumpWidget(_testApp(repository));
    await _fillValidData(tester, email: 'ana@example.com');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('12345678'), findsOneWidget);
  });

  testWidgets('Éxito muestra successMessage', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidData(tester);

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Si los datos coinciden, recibirás una clave temporal en tu correo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('El éxito no modifica sesión ni navega', (tester) async {
    final observer = _CountingNavigatorObserver();
    await tester.pumpWidget(
      _testApp(_FakeAuthRepository(), observer: observer),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ForgotPasswordScreen)),
    );
    final pushesBeforeSubmit = observer.pushes;
    await _fillValidData(tester);

    await _submit(tester);
    await tester.pumpAndSettle();

    final session = container.read(authSessionControllerProvider);
    expect(session.isAuthenticated, isFalse);
    expect(observer.pushes, pushesBeforeSubmit);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('Callback volver al login', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _testApp(_FakeAuthRepository(), onBackToLogin: () => calls++),
    );

    await tester.tap(find.text('Volver al login'));
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('Sin overflow en pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Funciona con teclado visible y scroll', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await tester.ensureVisible(find.text('Solicitar clave temporal'));

    expect(find.text('Solicitar clave temporal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(
  _FakeAuthRepository repository, {
  NavigatorObserver? observer,
  VoidCallback? onBackToLogin,
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
      home: ForgotPasswordScreen(onBackToLogin: onBackToLogin),
    ),
  );
}

Future<void> _fillValidData(
  WidgetTester tester, {
  String email = 'user@example.com',
  String referralMatricula = '12345678',
}) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Correo'), email);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Matrícula de referido'),
    referralMatricula,
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Solicitar clave temporal'));
  await tester.tap(find.text('Solicitar clave temporal'));
  await tester.pump();
}

AuthSessionResult _result() {
  return const AuthSessionResult(
    token: 'token',
    tokenType: 'Bearer',
    user: Profile(
      id: 'profile-id',
      email: 'user@example.com',
      firstName: 'Ana',
      lastName: 'Perez',
      profileCompleted: true,
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  final forgotPasswordCompleters = Queue<Completer<void>>();
  final forgotPasswordCalls = <_ForgotPasswordCall>[];
  Object? forgotPasswordError;

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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {
    forgotPasswordCalls.add(
      _ForgotPasswordCall(email: email, referralMatricula: referralMatricula),
    );

    if (forgotPasswordError != null) {
      throw forgotPasswordError!;
    }

    if (forgotPasswordCompleters.isNotEmpty) {
      return forgotPasswordCompleters.removeFirst().future;
    }
  }
}

class _ForgotPasswordCall {
  const _ForgotPasswordCall({
    required this.email,
    required this.referralMatricula,
  });

  final String email;
  final String referralMatricula;

  @override
  bool operator ==(Object other) {
    return other is _ForgotPasswordCall &&
        other.email == email &&
        other.referralMatricula == referralMatricula;
  }

  @override
  int get hashCode => Object.hash(email, referralMatricula);

  @override
  String toString() {
    return 'ForgotPasswordCall(email: $email, '
        'referralMatricula: $referralMatricula)';
  }
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
