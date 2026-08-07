import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/profile.dart';

import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
  });

  final Profile profile;

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [

          CircleAvatar(
            radius: 40,
            child: Text(
              profile.nombre.isNotEmpty
                  ? profile.nombre[0].toUpperCase()
                  : "?",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "${profile.firstName} ${profile.lastName}",
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Editar perfil"),
              onPressed: () async {
                final updated = await context.pushNamed<bool>(
                  RouteNames.editProfile,
                  extra: profile,
                );

                if (updated == true && context.mounted) {
                  // Lo manejaremos desde ProfileScreen
                }
              },
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Correo"),
            subtitle: Text(profile.email),
          ),

          ListTile(
            leading: const Icon(Icons.school),
            title: const Text("Matrícula"),
            subtitle: Text(profile.matricula),
          ),

          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text("Cédula"),
            subtitle: Text(profile.cedula),
          ),

          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text("Fecha de nacimiento"),
            subtitle: Text(
              _formatDate(profile.birthDate),
            ),
          ),
        ],
      ),
    );
  }
}