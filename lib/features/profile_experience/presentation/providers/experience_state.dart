import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/experience.dart';

const _unset = Object();

class ExperienceState extends Equatable{
  ExperienceState({
    required this.isInitialLoading,
    required this.isRefreshing,
    required List<Experience> items,
    required this.error,
  }) : items = List.unmodifiable(items);

  factory ExperienceState.initial(){
    return ExperienceState(
      isInitialLoading: false,
      isRefreshing: false,
      items: const [],
      error: null,
    );
  }

  final bool isInitialLoading;
  final bool isRefreshing;

  final List<Experience> items;

  final AppException? error;

  bool get hasError => error != null;

  bool get isEmpty => !isInitialLoading && !isRefreshing && items.isEmpty;

  ExperienceState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    List<Experience>? items,
    Object? error = _unset,
  }){
    return ExperienceState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      items: items ?? this.items,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    isRefreshing,
    items,
    error,
  ];
}