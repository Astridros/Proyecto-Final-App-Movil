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
import 'package:ocupa2/features/auth/presentation/pages/register_screen.dart';
import 'package:ocupa2/features/auth/presentation/widgets/register_form.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  testWidgets('render', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(RegisterForm), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('todos los campos', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(find.widgetWithText(TextFormField, 'Nombre'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Apellido'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Correo'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Matrícula de referido'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Confirmar contraseña'),
      findsOneWidget,
    );
  });

  testWidgets('nombre requerido', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, firstName: '');

    await _submit(tester);

    expect(find.text('Nombre requerido'), findsOneWidget);
  });

  testWidgets('apellido requerido', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, lastName: '');

    await _submit(tester);

    expect(find.text('Apellido requerido'), findsOneWidget);
  });

  testWidgets('correo requerido', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, email: '');

    await _submit(tester);

    expect(find.text('Correo requerido'), findsOneWidget);
  });

  testWidgets('correo válido', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, email: 'correo-invalido');

    await _submit(tester);

    expect(find.text('Correo inválido'), findsOneWidget);
  });

  testWidgets('matrícula requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, referralMatricula: '');

    await _submit(tester);

    expect(find.text('Matrícula requerida'), findsOneWidget);
  });

  testWidgets('matrícula exactamente de 8 dígitos', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, referralMatricula: '1234567');

    await _submit(tester);

    expect(find.text('Matrícula debe tener 8 dígitos'), findsOneWidget);
  });

  testWidgets('matrícula solo números', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, referralMatricula: '12AB5678');

    await _submit(tester);

    expect(find.text('Matrícula solo numérica'), findsOneWidget);
  });

  testWidgets('contraseña requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, password: '', confirmPassword: '');

    await _submit(tester);

    expect(find.text('Contraseña requerida'), findsOneWidget);
  });

  testWidgets('contraseña mínimo 8 caracteres', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(
      tester,
      password: 'secret1',
      confirmPassword: 'secret1',
    );

    await _submit(tester);

    expect(
      find.text('Contraseña debe tener al menos 8 caracteres'),
      findsOneWidget,
    );
  });

  testWidgets('confirmar contraseña requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, confirmPassword: '');

    await _submit(tester);

    expect(find.text('Confirmar contraseña requerida'), findsOneWidget);
  });

  testWidgets('ambas contraseñas deben coincidir', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await _fillValidRegister(tester, confirmPassword: 'otraClave');

    await _submit(tester);

    expect(find.text('Las contraseñas deben coincidir'), findsOneWidget);
  });

  testWidgets('mostrar/ocultar contraseña', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(_editableText(tester, 'Contraseña').obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();

    expect(_editableText(tester, 'Contraseña').obscureText, isFalse);
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
  });

  testWidgets('mostrar/ocultar confirmar contraseña', (tester) async {
    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    await tester.ensureVisible(find.byTooltip('Mostrar confirmar contraseña'));
    await tester.pump();

    expect(_editableText(tester, 'Confirmar contraseña').obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar confirmar contraseña'));
    await tester.pump();

    expect(_editableText(tester, 'Confirmar contraseña').obscureText, isFalse);
    expect(find.byTooltip('Ocultar confirmar contraseña'), findsOneWidget);
  });

  testWidgets('trim correcto', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));
    await _fillValidRegister(
      tester,
      firstName: '  Ana  ',
      lastName: '  Pérez  ',
      email: '  ana@example.com  ',
      referralMatricula: '  12345678  ',
    );

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.registerCalls.single.firstName, 'Ana');
    expect(repository.registerCalls.single.lastName, 'Pérez');
    expect(repository.registerCalls.single.email, 'ana@example.com');
    expect(repository.registerCalls.single.referralMatricula, '12345678');
  });

  testWidgets('contraseña sin trim', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));
    await _fillValidRegister(
      tester,
      password: '  secret123  ',
      confirmPassword: '  secret123  ',
    );

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.registerCalls.single.password, '  secret123  ');
  });

  testWidgets('loading', (tester) async {
    final repository = _FakeAuthRepository();
    final completer = Completer<AuthSessionResult>();
    repository.registerCompleters.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await _fillValidRegister(tester);

    await _submit(tester);
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    completer.complete(_result());
    await tester.pumpAndSettle();
  });

  testWidgets('impide doble submit mientras registra', (tester) async {
    final repository = _FakeAuthRepository();
    final completer = Completer<AuthSessionResult>();
    repository.registerCompleters.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await _fillValidRegister(tester);

    await _submit(tester);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();

    expect(repository.registerCalls, hasLength(1));
    completer.complete(_result());
    await tester.pumpAndSettle();
  });

  testWidgets('error', (tester) async {
    final repository = _FakeAuthRepository();
    repository.registerError = const ApiException(message: 'Correo registrado');
    await tester.pumpWidget(_testApp(repository));
    await _fillValidRegister(tester);

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Correo registrado'), findsOneWidget);
  });

  testWidgets('conservación de datos', (tester) async {
    final repository = _FakeAuthRepository();
    repository.registerError = const ApiException(message: 'Fallo');
    await tester.pumpWidget(_testApp(repository));
    await _fillValidRegister(tester, firstName: 'Astrid');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Astrid'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('12345678'), findsOneWidget);
  });

  testWidgets('callback volver al login', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _testApp(_FakeAuthRepository(), onBackToLogin: () => calls++),
    );

    await tester.ensureVisible(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.tap(find.text('¿Ya tienes cuenta? Inicia sesión'));
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('pantallas pequeñas', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('teclado', (tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(_testApp(_FakeAuthRepository()));
    await tester.ensureVisible(find.text('Registrarme'));

    expect(find.text('Registrarme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(_FakeAuthRepository repository, {VoidCallback? onBackToLogin}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: RegisterScreen(onBackToLogin: onBackToLogin),
    ),
  );
}

Future<void> _fillValidRegister(
  WidgetTester tester, {
  String firstName = 'Ana',
  String lastName = 'Perez',
  String email = 'user@example.com',
  String referralMatricula = '12345678',
  String password = 'secret123',
  String confirmPassword = 'secret123',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nombre'),
    firstName,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Apellido'),
    lastName,
  );
  await tester.enterText(find.widgetWithText(TextFormField, 'Correo'), email);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Matrícula de referido'),
    referralMatricula,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Contraseña'),
    password,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmar contraseña'),
    confirmPassword,
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Registrarme'));
  await tester.tap(find.text('Registrarme'));
  await tester.pump();
}

EditableText _editableText(WidgetTester tester, String label) {
  final field = find.widgetWithText(TextFormField, label);
  return tester.widget<EditableText>(
    find.descendant(of: field, matching: find.byType(EditableText)),
  );
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
  final registerCompleters = Queue<Completer<AuthSessionResult>>();
  final registerCalls = <_RegisterCall>[];
  Object? registerError;

  @override
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    registerCalls.add(
      _RegisterCall(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      ),
    );

    if (registerError != null) {
      throw registerError!;
    }

    if (registerCompleters.isNotEmpty) {
      return registerCompleters.removeFirst().future;
    }

    return _result();
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
  }) {
    throw UnimplementedError();
  }
}

class _RegisterCall {
  const _RegisterCall({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.referralMatricula,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String referralMatricula;
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
