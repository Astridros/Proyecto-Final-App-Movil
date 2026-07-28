import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ocupa2/app/app.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/widgets/app_button.dart';
import 'package:ocupa2/core/widgets/app_text_field.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/pages/offers_screen.dart';

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

  testWidgets('InitialScreen abre LoginPlaceholderScreen', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver login provisional'));
    await tester.pumpAndSettle();

    expect(find.text('Acceso a Ocupa2'), findsOneWidget);
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

  testWidgets('La pantalla de perfil muestra los campos provisionales reales', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Completar perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Cédula'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Apellido'), findsOneWidget);
    expect(find.text('Género'), findsOneWidget);
    expect(find.text('Fecha de nacimiento'), findsOneWidget);
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

Widget _testApp() {
  return ProviderScope(
    overrides: [
      offersRepositoryProvider.overrideWithValue(_FakeOffersRepository()),
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
