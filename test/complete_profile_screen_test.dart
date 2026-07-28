import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/widgets/app_error_view.dart';
import 'package:ocupa2/core/widgets/app_loading.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';
import 'package:ocupa2/features/profile/presentation/pages/complete_profile_screen.dart';
import 'package:ocupa2/features/profile/presentation/widgets/profile_form.dart';

void main() {
  testWidgets('Loading inicial', (tester) async {
    final repository = _FakeProfileRepository();
    repository.profileCompleters.add(Completer<Profile>());

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.byType(AppLoading), findsOneWidget);
  });

  testWidgets('Error inicial con reintento', (tester) async {
    final repository = _FakeProfileRepository();
    repository.profileErrors.add(const ApiException(message: 'Fallo inicial'));

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Fallo inicial'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repository.getProfileCalls, 2);
    expect(find.byType(ProfileForm), findsOneWidget);
  });

  testWidgets('Formulario con campos vacios', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _emptyProfile())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Apellido'), findsOneWidget);
    expect(find.text('Cédula'), findsOneWidget);
    expect(find.text('Género'), findsOneWidget);
    expect(find.text('Fecha de nacimiento'), findsOneWidget);
  });

  testWidgets('Precarga datos del perfil', (tester) async {
    await tester.pumpWidget(_testApp(_FakeProfileRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Astrid'), findsOneWidget);
    expect(find.text('Diaz'), findsOneWidget);
    expect(find.text('00112345678'), findsOneWidget);
    expect(find.text('Femenino'), findsOneWidget);
    expect(find.text('12/05/1997'), findsOneWidget);
  });

  testWidgets('Validacion de nombre requerido', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _validProfile(firstName: ''))),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Nombre requerido'), findsOneWidget);
  });

  testWidgets('Validacion de apellido requerido', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _validProfile(lastName: ''))),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Apellido requerido'), findsOneWidget);
  });

  testWidgets('Validacion de cedula requerida', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _validProfile(cedula: ''))),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Cédula requerida'), findsOneWidget);
  });

  testWidgets('Cedula no numerica', (tester) async {
    await tester.pumpWidget(
      _testApp(
        _FakeProfileRepository(profile: _validProfile(cedula: '001ABC45678')),
      ),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Cédula solo numérica'), findsOneWidget);
  });

  testWidgets('Cedula con longitud incorrecta', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _validProfile(cedula: '123'))),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Cédula debe tener 11 dígitos'), findsOneWidget);
  });

  testWidgets('Genero requerido', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _validProfile(gender: null))),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Género requerido'), findsOneWidget);
  });

  testWidgets('Fecha requerida', (tester) async {
    await tester.pumpWidget(
      _testApp(_FakeProfileRepository(profile: _validProfile(birthDate: null))),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Fecha de nacimiento requerida'), findsOneWidget);
  });

  testWidgets('Fecha futura invalida', (tester) async {
    await tester.pumpWidget(
      _testApp(
        _FakeProfileRepository(
          profile: _validProfile(
            birthDate: DateTime.now().add(const Duration(days: 1)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(
      find.text('Fecha de nacimiento no puede ser futura'),
      findsOneWidget,
    );
  });

  testWidgets('Menor de 18 anos invalido', (tester) async {
    await tester.pumpWidget(
      _testApp(
        _FakeProfileRepository(
          profile: _validProfile(birthDate: _yearsAgo(17)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(find.text('Debes tener al menos 18 años'), findsOneWidget);
  });

  testWidgets('Usuario de 18 anos valido', (tester) async {
    final repository = _FakeProfileRepository(
      profile: _validProfile(birthDate: _yearsAgo(18)),
    );
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(repository.updateCalls, hasLength(1));
    expect(find.text('Debes tener al menos 18 años'), findsNothing);
  });

  testWidgets('Submit envia valores correctos', (tester) async {
    final repository = _FakeProfileRepository(
      profile: _validProfile(firstName: '  Astrid  ', lastName: '  Diaz  '),
    );
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(
      repository.updateCalls.single,
      _UpdateCall(
        firstName: 'Astrid',
        lastName: 'Diaz',
        cedula: '00112345678',
        gender: 'femenino',
        birthDate: DateTime.utc(1997, 5, 12),
      ),
    );
  });

  testWidgets('Boton deshabilitado durante isSubmitting', (tester) async {
    final repository = _FakeProfileRepository();
    final completer = Completer<Profile>();
    repository.updateCompleters.add(completer);
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await _submit(tester);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    completer.complete(_validProfile());
  });

  testWidgets('Error de submit conserva los datos', (tester) async {
    final repository = _FakeProfileRepository();
    repository.updateErrors.add(const ApiException(message: 'No se guardo'));
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Ana');
    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se guardo'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
  });

  testWidgets('Exito muestra confirmacion', (tester) async {
    await tester.pumpWidget(_testApp(_FakeProfileRepository()));
    await tester.pumpAndSettle();

    await _submit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Perfil actualizado correctamente'), findsOneWidget);
  });

  testWidgets('Sin overflow en pantalla pequena', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeProfileRepository()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Funciona con teclado visible y scroll', (tester) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(_FakeProfileRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextFormField, 'Nombre'));
    await tester.pump();
    await tester.ensureVisible(find.text('Guardar perfil'));

    expect(find.text('Guardar perfil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(_FakeProfileRepository repository) {
  return ProviderScope(
    overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const CompleteProfileScreen(),
    ),
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Guardar perfil'));
  await tester.tap(find.text('Guardar perfil'));
  await tester.pump();
}

Profile _emptyProfile() {
  return const Profile(
    id: 'profile-empty',
    email: 'empty@example.com',
    profileCompleted: false,
  );
}

Profile _validProfile({
  String firstName = 'Astrid',
  String lastName = 'Diaz',
  String cedula = '00112345678',
  String? gender = 'femenino',
  Object? birthDate = _defaultBirthDate,
}) {
  return Profile(
    id: 'profile-1',
    email: 'astrid@example.com',
    firstName: firstName,
    lastName: lastName,
    nombre: 'Astrid Diaz',
    referralMatricula: 'MAT-001',
    role: 'worker',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
    birthDate: identical(birthDate, _defaultBirthDate)
        ? DateTime.utc(1997, 5, 12)
        : birthDate as DateTime?,
    cedula: cedula,
    gender: gender,
    profileCompleted: false,
  );
}

const _defaultBirthDate = Object();

DateTime _yearsAgo(int years) {
  final today = DateTime.now();
  return DateTime(today.year - years, today.month, today.day);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({Profile? profile, Profile? updatedProfile})
    : profile = profile ?? _validProfile(),
      updatedProfile =
          updatedProfile ?? _validProfile(firstName: 'Actualizado');

  final Profile profile;
  final Profile updatedProfile;
  final profileCompleters = Queue<Completer<Profile>>();
  final updateCompleters = Queue<Completer<Profile>>();
  final profileErrors = Queue<Object>();
  final updateErrors = Queue<Object>();
  final updateCalls = <_UpdateCall>[];
  int getProfileCalls = 0;

  @override
  Future<Profile> getProfile() async {
    getProfileCalls++;
    if (profileErrors.isNotEmpty) {
      throw profileErrors.removeFirst();
    }

    if (profileCompleters.isNotEmpty) {
      return profileCompleters.removeFirst().future;
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
    updateCalls.add(
      _UpdateCall(
        firstName: firstName,
        lastName: lastName,
        cedula: cedula,
        gender: gender,
        birthDate: birthDate,
      ),
    );

    if (updateErrors.isNotEmpty) {
      throw updateErrors.removeFirst();
    }

    if (updateCompleters.isNotEmpty) {
      return updateCompleters.removeFirst().future;
    }

    return updatedProfile;
  }
}

class _UpdateCall {
  const _UpdateCall({
    required this.firstName,
    required this.lastName,
    required this.cedula,
    required this.gender,
    required this.birthDate,
  });

  final String firstName;
  final String lastName;
  final String cedula;
  final String gender;
  final DateTime birthDate;

  @override
  bool operator ==(Object other) {
    return other is _UpdateCall &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.cedula == cedula &&
        other.gender == gender &&
        other.birthDate == birthDate;
  }

  @override
  int get hashCode {
    return Object.hash(firstName, lastName, cedula, gender, birthDate);
  }

  @override
  String toString() {
    return 'UpdateCall(firstName: $firstName, lastName: $lastName, '
        'cedula: $cedula, gender: $gender, birthDate: $birthDate)';
  }
}
