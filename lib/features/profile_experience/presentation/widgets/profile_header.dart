import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../profile/domain/entities/profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            _displayName,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar perfil'),
              onPressed: () => context.pushNamed<bool>(
                RouteNames.editProfile,
                extra: profile,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Correo'),
            subtitle: Text(profile.email),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Matrícula'),
            subtitle: Text(profile.referralMatricula ?? 'No especificada'),
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Cédula'),
            subtitle: Text(profile.cedula ?? 'No especificada'),
          ),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Fecha de nacimiento'),
            subtitle: Text(_formatDate(profile.birthDate)),
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final fullName = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'
        .trim();
    return fullName.isNotEmpty ? fullName : (profile.nombre ?? profile.email);
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'No especificada';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
