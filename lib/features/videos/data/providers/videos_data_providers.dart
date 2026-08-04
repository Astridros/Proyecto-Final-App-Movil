// Angel Daniel Genao 2024-1169
// Arma la capa "data" de videos con Riverpod: el datasource del backend
// de Ocupa2 (usa el ApiClient compartido, apiClientProvider) y el
// repositorio.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_remote_datasource.dart';
import '../repositories/videos_repository_impl.dart';

final videosRemoteDataSourceProvider = Provider<VideosRemoteDataSource>((ref) {
  return OcupaBackendVideosRemoteDataSource(ref.watch(apiClientProvider));
});

final videosRepositoryProvider = Provider<VideosRepository>((ref) {
  return VideosRepositoryImpl(ref.watch(videosRemoteDataSourceProvider));
});
