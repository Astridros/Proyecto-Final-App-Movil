import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/widgets/app_empty_state.dart';
import 'package:ocupa2/core/widgets/app_error_view.dart';
import 'package:ocupa2/core/widgets/app_loading.dart';
import 'package:ocupa2/features/payments/data/models/payment_model.dart';
import 'package:ocupa2/features/payments/data/providers/my_payments_data_providers.dart';
import 'package:ocupa2/features/payments/domain/entities/payment.dart';
import 'package:ocupa2/features/payments/domain/repositories/my_payments_repository.dart';
import 'package:ocupa2/features/payments/presentation/pages/my_payments_screen.dart';
import 'package:ocupa2/features/payments/presentation/widgets/payment_card.dart';

// Yeison Familia - pruebas del modulo Mis Pagos.
void main() {
  group('PaymentModel', () {
    test('Parsea un pago completo', () {
      final payment = PaymentModel.fromJson({
        'id': 'pay-1',
        'amount': 1,
        'currency': 'USD',
        'concept': 'Publicación de oferta',
        'status': 'approved',
        'cardLast4': '4242',
        'reference': 'REF-001',
        'createdAt': '2026-08-08T18:14:00.000Z',
      });

      expect(payment.id, 'pay-1');
      expect(payment.amount, 1.0);
      expect(payment.currency, 'USD');
      expect(payment.concept, 'Publicación de oferta');
      expect(payment.cardLast4, '4242');
      expect(payment.createdAt, isNotNull);
    });

    test('Acepta el monto como texto', () {
      final payment = PaymentModel.fromJson({'amount': '1.50'});

      expect(payment.amount, 1.5);
    });

    test('Acepta nombres alternos de campo', () {
      final payment = PaymentModel.fromJson({
        '_id': 'pay-2',
        'monto': 2,
        'moneda': 'DOP',
        'concepto': 'Otro concepto',
        'estado': 'pendiente',
        'last4': '1881',
      });

      expect(payment.id, 'pay-2');
      expect(payment.amount, 2.0);
      expect(payment.currency, 'DOP');
      expect(payment.concept, 'Otro concepto');
      expect(payment.status, 'pendiente');
      expect(payment.cardLast4, '1881');
    });

    test('No revienta con un objeto vacio', () {
      final payment = PaymentModel.fromJson(const {});

      expect(payment.id, '');
      expect(payment.amount, 0);
      expect(payment.currency, 'USD');
      expect(payment.concept, 'Pago en Ocupa2');
      expect(payment.createdAt, isNull);
    });

    test('Ignora una fecha invalida en vez de fallar', () {
      final payment = PaymentModel.fromJson({'createdAt': 'no es una fecha'});

      expect(payment.createdAt, isNull);
    });
  });

  group('MyPaymentsScreen', () {
    testWidgets('Muestra loading mientras carga', (tester) async {
      final repository = _FakeMyPaymentsRepository();
      repository.completers.add(Completer<List<Payment>>());

      await tester.pumpWidget(_testApp(repository));
      await tester.pump();

      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('Muestra los pagos recibidos', (tester) async {
      final repository = _FakeMyPaymentsRepository(
        payments: [_payment(id: 'p1'), _payment(id: 'p2')],
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentCard), findsNWidgets(2));
      expect(find.text('1.00 USD'), findsNWidgets(2));
      expect(find.text('Aprobado'), findsNWidgets(2));
      expect(find.text('•••• 4242'), findsNWidgets(2));
    });

    testWidgets('Muestra el estado vacio', (tester) async {
      await tester.pumpWidget(_testApp(_FakeMyPaymentsRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Aún no has hecho pagos'), findsOneWidget);
    });

    testWidgets('Muestra el error y permite reintentar', (tester) async {
      final repository = _FakeMyPaymentsRepository();
      repository.errors.add(const ApiException(message: 'Fallo la carga'));

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Fallo la carga'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(repository.calls, 2);
      expect(find.byType(AppEmptyState), findsOneWidget);
    });

    testWidgets('Traduce el estado rechazado', (tester) async {
      final repository = _FakeMyPaymentsRepository(
        payments: [_payment(id: 'p1', status: 'declined')],
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Rechazado'), findsOneWidget);
    });

    testWidgets('Muestra tal cual un estado desconocido', (tester) async {
      final repository = _FakeMyPaymentsRepository(
        payments: [_payment(id: 'p1', status: 'reembolsado')],
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('reembolsado'), findsOneWidget);
    });
  });
}

Widget _testApp(MyPaymentsRepository repository) {
  return ProviderScope(
    overrides: [myPaymentsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const MyPaymentsScreen(),
    ),
  );
}

Payment _payment({required String id, String status = 'approved'}) {
  return Payment(
    id: id,
    amount: 1,
    currency: 'USD',
    concept: 'Publicación de oferta',
    status: status,
    cardLast4: '4242',
    reference: 'REF-$id',
    createdAt: DateTime(2026, 8, 8, 14, 14),
    declineReason: null,
  );
}

class _FakeMyPaymentsRepository implements MyPaymentsRepository {
  _FakeMyPaymentsRepository({this.payments = const []});

  final List<Payment> payments;
  final List<Completer<List<Payment>>> completers = [];
  final List<Object> errors = [];
  int calls = 0;

  @override
  Future<List<Payment>> getMyPayments() {
    calls++;

    if (completers.isNotEmpty) {
      return completers.removeAt(0).future;
    }

    if (errors.isNotEmpty) {
      return Future.error(errors.removeAt(0));
    }

    return Future.value(payments);
  }
}
