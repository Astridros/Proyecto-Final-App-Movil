import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ocupa2/app/app.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/widgets/app_button.dart';
import 'package:ocupa2/core/widgets/app_text_field.dart';

void main() {
  testWidgets('App se construye correctamente', (tester) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('La pantalla inicial muestra Ocupa2', (tester) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    expect(find.text('Ocupa2'), findsOneWidget);
  });

  testWidgets('InitialScreen abre LoginPlaceholderScreen', (tester) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver login provisional'));
    await tester.pumpAndSettle();

    expect(find.text('Acceso a Ocupa2'), findsOneWidget);
  });

  testWidgets('El boton Volver regresa correctamente a InitialScreen', (
    tester,
  ) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver login provisional'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();

    expect(find.text('Base provisional'), findsOneWidget);
    expect(find.text('Acceso a Ocupa2'), findsNothing);
  });

  testWidgets('La pantalla de ofertas se construye sin error de locale', (
    tester,
  ) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explorar ofertas'));
    await tester.tap(find.text('Explorar ofertas'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Explorar ofertas'), findsOneWidget);
    expect(find.text('22/07/2026'), findsOneWidget);
  });

  testWidgets('Los chips permiten cambiar al estado de carga', (tester) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explorar ofertas'));
    await tester.tap(find.text('Explorar ofertas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Carga'));
    await tester.pump();

    expect(find.text('Estado de carga demostrativo.'), findsOneWidget);
  });

  testWidgets('Los chips permiten cambiar al estado vacío', (tester) async {
    await tester.pumpWidget(const Ocupa2App());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explorar ofertas'));
    await tester.tap(find.text('Explorar ofertas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vacío'));
    await tester.pumpAndSettle();

    expect(find.text('Sin ofertas para mostrar'), findsOneWidget);
  });

  testWidgets('La pantalla de perfil muestra los campos provisionales reales', (
    tester,
  ) async {
    await tester.pumpWidget(const Ocupa2App());
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
