import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final hasAuthorization = options.headers.keys.any(
      (key) =>
          key.toLowerCase() == ApiConstants.authorizationHeader.toLowerCase(),
    );

    if (!hasAuthorization) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] = 'Bearer $token';
      }
    }

    handler.next(options);
  }
}
