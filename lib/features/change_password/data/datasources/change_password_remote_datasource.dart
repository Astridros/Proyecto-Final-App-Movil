import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/change_password_request_model.dart';

abstract interface class ChangePasswordRemoteDataSource {
  Future<void> changePassword(ChangePasswordRequestModel request);
}

class ChangePasswordRemoteDataSourceImpl
    implements ChangePasswordRemoteDataSource {
  const ChangePasswordRemoteDataSourceImpl(this._apiClient);

  static const _changePasswordPath = '/me/password';

  final ApiClient _apiClient;

  @override
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    final response = await _apiClient.put<Object?>(
      _changePasswordPath,
      data: request.toJson(),
    );

    _validateResponse(response.data);
  }

  void _validateResponse(Object? data) {
    if (data is! Map) {
      throw const ApiException(
        message: 'Respuesta inválida al cambiar la contraseña.',
      );
    }

    if (data['ok'] != true) {
      throw ApiException(
        message:
            _extractMessage(data) ?? 'No fue posible cambiar la contraseña.',
      );
    }

    final payload = data['data'];
    if (payload != null && payload is! Map) {
      throw const ApiException(
        message: 'Respuesta inválida al cambiar la contraseña.',
      );
    }
  }

  String? _extractMessage(Map<dynamic, dynamic> data) {
    final candidates = [data['message'], data['error']];
    final payload = data['data'];
    if (payload is Map) {
      candidates.addAll([payload['message'], payload['error']]);
    }

    for (final value in candidates) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}
