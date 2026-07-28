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
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/pages/offers_screen.dart';
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

  testWidgets('La pantalla inicial muestra Ocupa2', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Ocupa2'), findsOneWidget);
  });

  testWidgets('El acceso permanente Completar perfil no aparece', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Completar perfil'), findsNothing);
  });

  testWidgets('InitialScreen abre LoginPlaceholderScreen', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver login provisional'));
    await tester.pumpAndSettle();

    expect(find.text('Acceso a Ocupa2'), findsOneWidget);
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

    expect(find.text('Base provisional'), findsOneWidget);
    expect(find.text('Validando sesión...'), findsNothing);
  });

  testWidgets('El boton Volver regresa correctamente a InitialScreen', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver login provisional'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();

    expect(find.text('Base provisional'), findsOneWidget);
    expect(find.text('Acceso a Ocupa2'), findsNothing);
  });

  testWidgets('La ruta de ofertas abre OffersScreen', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explorar ofertas'));
    await tester.tap(find.text('Explorar ofertas'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(OffersScreen), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
  });

  testWidgets('OffersScreen carga datos del repositorio', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explorar ofertas'));
    await tester.tap(find.text('Explorar ofertas'));
    await tester.pumpAndSettle();

    expect(find.text('Chofer'), findsWidgets);
    expect(
      find.text('Se necesita chofer con disponibilidad inmediata.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'profileCompleted false exige CompleteProfileScreen y desbloquea al guardar',
    (tester) async {
      final profileRepository = _FakeProfileRepository();
      await tester.pumpWidget(
        _testApp(profileRepository: profileRepository, hasToken: true),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompleteProfileScreen), findsOneWidget);
      expect(profileRepository.getProfileCalls, 1);
      expect(find.text('Astrid'), findsWidgets);
      expect(find.text('Diaz'), findsWidgets);
      expect(find.text('00112345678'), findsWidgets);

      expect(find.text('Cédula'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Apellido'), findsOneWidget);
      expect(find.text('Género'), findsOneWidget);
      expect(find.text('Fecha de nacimiento'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Ana',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Apellido'),
        'Perez',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cédula'),
        '40212345678',
      );
      await tester.ensureVisible(find.text('Guardar perfil'));
      await tester.tap(find.text('Guardar perfil'));
      await tester.pumpAndSettle();

      expect(profileRepository.updateProfileCalls, 1);
      expect(profileRepository.profile.profileCompleted, isTrue);
      await tester.pumpAndSettle();

      expect(find.byType(CompleteProfileScreen), findsNothing);
      expect(find.text('Base provisional'), findsOneWidget);
      expect(find.text('Completar perfil'), findsNothing);
    },
  );

  testWidgets('profileCompleted false no puede abrir rutas normales', (
    tester,
  ) async {
    final profileRepository = _FakeProfileRepository();
    await tester.pumpWidget(
      _testApp(profileRepository: profileRepository, hasToken: true),
    );
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.byType(CompleteProfileScreen)),
    ).go(RouteNames.offersPath);
    await tester.pumpAndSettle();

    expect(find.byType(CompleteProfileScreen), findsOneWidget);
    expect(find.byType(OffersScreen), findsNothing);
  });

  testWidgets('profileCompleted true entra a la ruta principal', (
    tester,
  ) async {
    final profileRepository = _FakeProfileRepository(profileCompleted: true);
    await tester.pumpWidget(
      _testApp(profileRepository: profileRepository, hasToken: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Base provisional'), findsOneWidget);
    expect(find.byType(CompleteProfileScreen), findsNothing);
    expect(find.text('Completar perfil'), findsNothing);
  });

  testWidgets('profileCompleted true no es redirigido a complete profile', (
    tester,
  ) async {
    final profileRepository = _FakeProfileRepository(profileCompleted: true);
    await tester.pumpWidget(
      _testApp(profileRepository: profileRepository, hasToken: true),
    );
    await tester.pumpAndSettle();

    GoRouter.of(
      tester.element(find.text('Ocupa2')),
    ).go(RouteNames.completeProfilePath);
    await tester.pumpAndSettle();

    expect(find.text('Base provisional'), findsOneWidget);
    expect(find.byType(CompleteProfileScreen), findsNothing);
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

  testWidgets('AppTextField muestra error de validaciÃ³n', (tester) async {
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
  _FakeProfileRepository? profileRepository,
  bool hasToken = false,
}) {
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(
        _FakeTokenStorage(hasToken ? 'token' : null),
      ),
      offersRepositoryProvider.overrideWithValue(_FakeOffersRepository()),
      profileRepositoryProvider.overrideWithValue(
        profileRepository ?? _FakeProfileRepository(),
      ),
    ],
    child: const Ocupa2App(),
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
    address: 'Santo Domingo, RepÃºblica Dominicana',
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

class _FakeOffersRepository implements OffersRepository {
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
  int updateProfileCalls = 0;

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
    updateProfileCalls++;
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
    _token = null;
  }
}
