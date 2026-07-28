import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/token_storage.dart';

const _devToken = String.fromEnvironment('OCUPA2_DEV_TOKEN');

/// Enables temporary authenticated API testing without touching the login flow.
Future<void> bootstrapDevAuthToken({
  String devToken = _devToken,
  bool isDebugMode = kDebugMode,
  TokenStorage? tokenStorage,
}) async {
  if (!isDebugMode) {
    return;
  }

  final normalizedToken = devToken.trim();
  if (normalizedToken.isEmpty) {
    return;
  }

  final storage =
      tokenStorage ?? const SecureTokenStorage(FlutterSecureStorage());
  await storage.saveAccessToken(normalizedToken);
}
