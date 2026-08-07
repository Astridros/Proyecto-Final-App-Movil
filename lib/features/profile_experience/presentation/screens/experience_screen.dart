import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/experience_presentation_providers.dart';
import '../widgets/experience_card.dart';
import '../providers/profile_presentation_providers.dart';
import '../widgets/profile_header.dart';

class ExperienceScreen extends ConsumerStatefulWidget {
  const ExperienceScreen({super.key});

  @override
  ConsumerState<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends ConsumerState<ExperienceScreen>{

  @override
  void initState(){
    super.initState();

    Future.microtask(() {
      ref
          .read(profileControllerProvider.notifier)
          .loadProfile();

      ref
          .read(experienceControllerProvider.notifier)
          .loadInitial();
    });
  }

  @override
  Widget build(BuildContext context){
    final state = ref.watch(
      experienceControllerProvider,
    );

    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis experiencias'),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     context.pushNamed(RouteNames.addExperience);
      //   },

      //   child: const Icon(Icons.add),
      // ),

      body: RefreshIndicator(
        onRefresh: () => ref.read(experienceControllerProvider.notifier).refresh(),

        child: Builder(
          builder: (_){
            if (state.isInitialLoading){
              return const AppLoading(
                message: "Cargando experiencias...",
              );
            }

            if (state.hasError){
              return AppErrorView(
                title: 'Error',
                message: state.error!.message,
                onRetry: (){
                  ref.read(experienceControllerProvider.notifier).retry();
                },
              );
            }

            if (state.isEmpty) {
              return const AppEmptyState(
                icon: Icons.work_outline,
                title: 'Sin experiencias',
                description: 'Todavía no has agregado experiencias.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [

                if (profileState.profile != null)
                  ProfileHeader(
                    profile: profileState.profile!,
                  ),
                
                const Text(
                  "Experiencias",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ...state.items.map(
                  (experience) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ExperienceCard(
                      experience: experience,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}