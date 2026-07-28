import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/app/theme/app_theme.dart';
import 'package:ocupa2/features/offers/domain/constants/contract_types.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_location.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_payment.dart';
import 'package:ocupa2/features/offers/presentation/widgets/offer_card.dart';

void main() {
  testWidgets('render con datos completos', (tester) async {
    await tester.pumpWidget(_testApp(OfferCard(offer: _offer())));

    expect(find.text('Chofer'), findsOneWidget);
    expect(find.text('Santo Domingo, República Dominicana'), findsOneWidget);
    expect(find.text('DOP 35,000 · total'), findsOneWidget);
    expect(find.text('Temporal'), findsOneWidget);
    expect(find.text('Fecha límite 30/08/2026'), findsOneWidget);
    expect(find.textContaining('Se necesita chofer'), findsOneWidget);
  });

  testWidgets('render sin imagen muestra placeholder', (tester) async {
    await tester.pumpWidget(_testApp(OfferCard(offer: _offer(photo: ''))));

    expect(find.byIcon(Icons.work_outline_rounded), findsOneWidget);
  });

  testWidgets('imagen inválida usa placeholder', (tester) async {
    await tester.pumpWidget(
      _testApp(OfferCard(offer: _offer(photo: 'string'))),
    );

    expect(find.byIcon(Icons.work_outline_rounded), findsOneWidget);
  });

  testWidgets('deadline null no renderiza fecha límite', (tester) async {
    await tester.pumpWidget(_testApp(OfferCard(offer: _offer(deadline: null))));

    expect(find.textContaining('Fecha límite'), findsNothing);
  });

  testWidgets('descripción larga usa máximo dos líneas', (tester) async {
    await tester.pumpWidget(
      _testApp(
        OfferCard(
          offer: _offer(
            description:
                'Descripción muy larga para validar que el componente mantiene '
                'un resumen visual compacto y no ocupa demasiado espacio dentro '
                'de los listados futuros de la aplicación.',
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(
      find.textContaining('Descripción muy larga'),
    );

    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('onTap ejecuta callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _testApp(OfferCard(offer: _offer(), onTap: () => taps++)),
    );

    await tester.tap(find.byType(OfferCard));

    expect(taps, 1);
  });

  testWidgets('salary ausente no se muestra', (tester) async {
    await tester.pumpWidget(
      _testApp(
        OfferCard(
          offer: _offer(
            payment: const OfferPayment(amount: 0, currency: '', period: ''),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.payments_outlined), findsNothing);
  });

  testWidgets('ubicación ausente no se muestra', (tester) async {
    await tester.pumpWidget(_testApp(OfferCard(offer: _offer(address: ''))));

    expect(find.byIcon(Icons.place_outlined), findsNothing);
  });

  testWidgets('no hay overflows en pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(
        OfferCard(
          offer: _offer(
            address:
                'Una ubicación extremadamente larga para verificar ellipsis en móvil pequeño',
            description:
                'Descripción muy larga para asegurar que el contenido no genere overflow en pantallas estrechas.',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

Offer _offer({
  String photo = 'https://example.test/image.png',
  Object? deadline = _defaultDeadline,
  String description = 'Se necesita chofer con disponibilidad inmediata.',
  String address = 'Santo Domingo, República Dominicana',
  OfferPayment payment = const OfferPayment(
    amount: 35000,
    currency: 'DOP',
    period: 'total',
  ),
}) {
  return Offer(
    id: 'offer-id',
    jobTypeKey: 'chofer',
    jobTypeName: 'Chofer',
    contractType: ContractTypes.temporal,
    description: description,
    address: address,
    location: const OfferLocation(lat: 18.4861, lng: -69.9312),
    payment: payment,
    photo: photo,
    deadline: identical(deadline, _defaultDeadline)
        ? DateTime(2026, 8, 30)
        : deadline as DateTime?,
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

const _defaultDeadline = Object();
