// Angel Daniel Genao 2024-1169
// Arma la capa "data" de noticias con Riverpod: el datasource del
// backend de Ocupa2 (usa el ApiClient compartido, apiClientProvider) y
// el repositorio.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';
import '../repositories/news_repository_impl.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return OcupaBackendNewsRemoteDataSource(ref.watch(apiClientProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(ref.watch(newsRemoteDataSourceProvider));
});
