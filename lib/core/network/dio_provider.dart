import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_provider.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref.watch(tokenStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: const {
        ApiConstants.acceptHeader: ApiConstants.jsonContentType,
        ApiConstants.contentTypeHeader: ApiConstants.jsonContentType,
      },
    ),
  );

  dio.interceptors.add(ref.watch(authInterceptorProvider));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
