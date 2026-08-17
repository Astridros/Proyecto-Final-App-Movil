import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile_experience/presentation/widgets/profile_header.dart';

void main() {
  testWidgets('ProfileHeader muestra valores seguros cuando faltan datos', (
    tester,
  ) async {
    const profile = Profile(
      id: '1',
      email: 'ana@example.com',
      profileCompleted: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileHeader(profile: profile)),
      ),
    );

    expect(find.text('ana@example.com'), findsNWidgets(2));
    expect(find.text('No especificada'), findsNWidgets(3));
    expect(find.text('Editar perfil'), findsOneWidget);
  });
}
