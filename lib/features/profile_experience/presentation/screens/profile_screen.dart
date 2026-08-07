import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

import '../../../profile_experience/presentation/providers/profile_presentation_providers.dart';
import '../../../profile_experience/presentation/widgets/profile_header.dart';

import '../providers/experience_presentation_providers.dart';
import '../widgets/experience_card.dart';

import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_empty_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends ConsumerState<ProfileScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(profileControllerProvider.notifier)
          .loadProfile();

      await ref
          .read(experienceControllerProvider.notifier)
          .loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {

    final profileState =
        ref.watch(profileControllerProvider);

    final experienceState =
        ref.watch(experienceControllerProvider);

    if (profileState.isLoading) {
      return const Scaffold(
        body: AppLoading(
          message: "Cargando perfil...",
        ),
      );
    }

    if (profileState.error != null) {
      return Scaffold(
        body: AppErrorView(
          title: "Error",
          message: profileState.error!.message,
        ),
      );
    }

    final profile = profileState.profile;

    if (profile == null) {
      return const Scaffold(
        body: AppEmptyState(
          icon: Icons.person,
          title: "Perfil vacío",
          description: "No se encontró información.",
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteNames.addExperience);
        },
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider.notifier)
              .loadProfile();

          await ref
              .read(experienceControllerProvider.notifier)
              .refresh();
        },

        child: ListView(
          children: [

            ProfileHeader(
              profile: profileState.profile!,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Experiencias",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                // IconButton(
                //   icon: const Icon(Icons.add),
                //   onPressed: () {
                //     context.pushNamed(RouteNames.addExperience);
                //   },
                // ),
                
              ],
            ),

            const SizedBox(height: 16),

            if (experienceState.isInitialLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (experienceState.items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No tienes experiencias registradas.",
                    ),
                  ),
                ),
              )
            else
              ...experienceState.items.map(
                (experience) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ExperienceCard(
                    experience: experience,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}