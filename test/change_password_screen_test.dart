import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/change_password/data/providers/change_password_data_providers.dart';
import 'package:ocupa2/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:ocupa2/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:ocupa2/features/change_password/presentation/widgets/change_password_form.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  testWidgets('Render de pantalla', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    expect(find.byType(ChangePasswordForm), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsWidgets);
  });

  testWidgets('Campo nueva contraseña visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    expect(
      find.widgetWithText(TextFormField, 'Nueva contraseña'),
      findsOneWidget,
    );
  });

  testWidgets('Campo confirmar contraseña visible', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    expect(
      find.widgetWithText(TextFormField, 'Confirmar nueva contraseña'),
      findsOneWidget,
    );
  });

  testWidgets('Nueva contraseña requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    await _submit(tester);

    expect(find.text('Nueva contraseña requerida'), findsOneWidget);
  });

  testWidgets('Contraseña con solo espacios inválida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await _fillPasswords(
      tester,
      password: '        ',
      confirmPassword: '        ',
    );

    await _submit(tester);

    expect(
      find.text('La contraseña no puede contener solo espacios'),
      findsOneWidget,
    );
  });

  testWidgets('Contraseña menor de 8 caracteres inválida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await _fillPasswords(tester, password: 'abc123', confirmPassword: 'abc123');

    await _submit(tester);

    expect(
      find.text('La contraseña debe tener al menos 8 caracteres'),
      findsOneWidget,
    );
  });

  testWidgets('Confirmación requerida', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nueva contraseña'),
      'NuevaClave123',
    );

    await _submit(tester);

    expect(find.text('Confirmación requerida'), findsOneWidget);
  });

  testWidgets('Contraseñas diferentes inválidas', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await _fillPasswords(
      tester,
      password: 'NuevaClave123',
      confirmPassword: 'OtraClave123',
    );

    await _submit(tester);

    expect(find.text('Las contraseñas deben coincidir'), findsOneWidget);
  });

  testWidgets('Mostrar/ocultar nueva contraseña', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    EditableText passwordEditableText() {
      final field = find.widgetWithText(TextFormField, 'Nueva contraseña');
      return tester.widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      );
    }

    expect(passwordEditableText().obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar nueva contraseña'));
    await tester.pump();

    expect(passwordEditableText().obscureText, isFalse);
    expect(find.byTooltip('Ocultar nueva contraseña'), findsOneWidget);
  });

  testWidgets('Mostrar/ocultar confirmación', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    EditableText confirmEditableText() {
      final field = find.widgetWithText(
        TextFormField,
        'Confirmar nueva contraseña',
      );
      return tester.widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      );
    }

    expect(confirmEditableText().obscureText, isTrue);

    await tester.tap(find.byTooltip('Mostrar confirmar nueva contraseña'));
    await tester.pump();

    expect(confirmEditableText().obscureText, isFalse);
    expect(
      find.byTooltip('Ocultar confirmar nueva contraseña'),
      findsOneWidget,
    );
  });

  testWidgets('Submit llama al controller con la contraseña exacta', (
    tester,
  ) async {
    final repository = _FakeChangePasswordRepository();
    await tester.pumpWidget(_testApp(repository));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.passwords.single, 'NuevaClave123');
  });

  testWidgets('No aplica trim', (tester) async {
    final repository = _FakeChangePasswordRepository();
    await tester.pumpWidget(_testApp(repository));
    await _fillPasswords(tester, password: '  NuevaClave123  ');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.passwords.single, '  NuevaClave123  ');
  });

  testWidgets('Loading deshabilita el botón', (tester) async {
    final repository = _FakeChangePasswordRepository();
    final completer = Completer<void>();
    repository.completers.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Evita doble submit', (tester) async {
    final repository = _FakeChangePasswordRepository();
    final completer = Completer<void>();
    repository.completers.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();

    expect(repository.passwords, ['NuevaClave123']);
    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Error se muestra', (tester) async {
    final repository = _FakeChangePasswordRepository()
      ..error = const ApiException(message: 'No fue posible cambiar la clave');
    await tester.pumpWidget(_testApp(repository));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('No fue posible cambiar la clave'), findsOneWidget);
  });

  testWidgets('Datos se conservan tras error', (tester) async {
    final repository = _FakeChangePasswordRepository()
      ..error = const ApiException(message: 'Fallo');
    await tester.pumpWidget(_testApp(repository));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('NuevaClave123'), findsWidgets);
  });

  testWidgets('Éxito muestra successMessage', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Contraseña actualizada correctamente.'), findsOneWidget);
  });

  testWidgets('Éxito limpia los campos', (tester) async {
    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pumpAndSettle();

    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.every((field) => field.controller.text.isEmpty), isTrue);
  });

  testWidgets('No modifica sesión ni navega', (tester) async {
    final observer = _CountingNavigatorObserver();
    await tester.pumpWidget(
      _testApp(_FakeChangePasswordRepository(), observer: observer),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ChangePasswordScreen)),
    );
    final sessionBefore = container.read(authSessionControllerProvider);
    final pushesBeforeSubmit = observer.pushes;
    await _fillPasswords(tester, password: 'NuevaClave123');

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(container.read(authSessionControllerProvider), sessionBefore);
    expect(observer.pushes, pushesBeforeSubmit);
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  testWidgets('Sin overflow en pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Funciona con teclado visible y scroll', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(_testApp(_FakeChangePasswordRepository()));
    await tester.ensureVisible(find.text('Cambiar contraseña').last);

    expect(find.text('Cambiar contraseña'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(
  _FakeChangePasswordRepository repository, {
  NavigatorObserver? observer,
}) {
  return ProviderScope(
    overrides: [
      changePasswordRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      navigatorObservers: [?observer],
      home: const ChangePasswordScreen(),
    ),
  );
}

Future<void> _fillPasswords(
  WidgetTester tester, {
  required String password,
  String? confirmPassword,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nueva contraseña'),
    password,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmar nueva contraseña'),
    confirmPassword ?? password,
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Cambiar contraseña').last);
  await tester.tap(find.text('Cambiar contraseña').last);
  await tester.pump();
}

class _FakeChangePasswordRepository implements ChangePasswordRepository {
  final completers = Queue<Completer<void>>();
  final passwords = <String>[];
  Object? error;

  @override
  Future<void> changePassword({required String password}) async {
    passwords.add(password);

    if (error != null) {
      throw error!;
    }

    if (completers.isNotEmpty) {
      return completers.removeFirst().future;
    }
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
  Future<Profile> getProfile() async {
    return const Profile(
      id: 'profile-id',
      email: 'user@example.com',
      profileCompleted: true,
    );
  }

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
    return const Profile(
      id: 'profile-id',
      email: 'user@example.com',
      profileCompleted: true,
    );
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
