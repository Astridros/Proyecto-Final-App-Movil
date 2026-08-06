import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';
import '../../data/providers/experience_data_providers.dart';
import '../../domain/entities/experience.dart';
import '../../domain/repositories/experience_repository.dart';

import 'experience_state.dart';

class ExperienceController extends Notifier<ExperienceState>{
  late final ExperienceRepository _repository;

  @override
  ExperienceState build(){
    _repository = ref.watch(experienceRepositoryProvider);
    return ExperienceState.initial();
  }

  Future<void> loadInitial() async{
    if (state.isInitialLoading) return;

    state = state.copyWith(
      isInitialLoading: true,
      error: null,
    );

    try {
      final experiences = await _repository.getExperiences();

      state = state.copyWith(
        items: experiences,
        error: null,
      );
    } catch (error){
      state = state.copyWith(
        error: _toAppException(error),
      );
    } finally {
      state = state.copyWith(
        isInitialLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(
      isRefreshing: true,
      error: null,
    );

    try {
      final experiences = await _repository.getExperiences(
        forceRefresh: true,
      );

      state = state.copyWith(
        items: experiences,
        error: null,
      );
    } catch (error){
      state = state.copyWith(
        error: _toAppException(error),
      );
    } finally {
      state = state.copyWith(
        isRefreshing: false,
      );
    }
  }

  Future<void> createExperience(
    Experience experience,
  ) async {
    try {
      await _repository.createExperience(experience);
      await refresh();
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _repository.deleteExperience(id);

      await refresh();
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );
    }
  }

  Future<void> retry() async {
    state = state.copyWith(
      isInitialLoading: false,
      error: null,
    );

    await loadInitial();
  }

  AppException _toAppException(Object error) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: 'Ocurrió un error inesperado.',
      cause: error,
    );
  }
}