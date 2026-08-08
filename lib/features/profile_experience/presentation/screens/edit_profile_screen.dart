import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_presentation_providers.dart';
import '../../../profile/presentation/widgets/profile_form.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileForm(
              profile: state.profile ?? profile,
              isSubmitting: state.isSubmitting,
              errorMessage: state.error?.message,
              showAccountFields: true,
              onSubmit:
                  ({
                    required firstName,
                    required lastName,
                    required cedula,
                    required gender,
                    required birthDate,
                    email,
                    referralMatricula,
                  }) async {
                    final saved = await ref
                        .read(profileControllerProvider.notifier)
                        .submitProfile(
                          firstName: firstName,
                          lastName: lastName,
                          cedula: cedula,
                          gender: gender,
                          birthDate: birthDate,
                          email: email,
                          referralMatricula: referralMatricula,
                        );
                    if (saved && context.mounted) context.pop(true);
                    return saved;
                  },
            ),
          ],
        ),
      ),
    );
  }
}
