import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'app_exception.dart';
import 'conflict_exception.dart';
import 'forbidden_exception.dart';
import 'network_exception.dart';
import 'not_found_exception.dart';
import 'server_exception.dart';
import 'timeout_exception.dart';
import 'unauthorized_exception.dart';
import 'unknown_exception.dart';
import 'validation_exception.dart';

class ErrorMapper {
  const ErrorMapper._();

  static AppException fromDioException(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.cancel => UnknownException(
        message: 'La solicitud fue cancelada.',
        cause: exception,
      ),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => TimeoutException(
        message: 'La solicitud tardó demasiado. Intenta nuevamente.',
        cause: exception,
      ),
      DioExceptionType.connectionError => NetworkException(
        message: 'No fue posible conectar con el servidor.',
        cause: exception,
      ),
      DioExceptionType.badCertificate => NetworkException(
        message: 'No fue posible validar la conexión segura.',
        cause: exception,
      ),
      DioExceptionType.badResponse => _fromResponse(exception),
      DioExceptionType.unknown => UnknownException(
        message: 'Ocurrió un error inesperado.',
        cause: exception,
      ),
    };
  }

  static AppException fromObject(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return fromDioException(error);
    }

    return UnknownException(
      message: 'Ocurrió un error inesperado.',
      cause: error,
    );
  }

  static AppException _fromResponse(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final effectiveStatusCode = statusCode ?? -1;
    final data = response?.data;
    final extractedMessage = _extractMessage(data);
    final details = _extractDetails(data);

    return switch (effectiveStatusCode) {
      400 => ApiException(
        message: extractedMessage ?? 'La solicitud contiene datos inválidos.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      401 => UnauthorizedException(
        message: extractedMessage ?? 'Tu sesión no es válida o ha expirado.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      403 => ForbiddenException(
        message:
            extractedMessage ?? 'No tienes permisos para realizar esta acción.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      404 => NotFoundException(
        message:
            extractedMessage ?? 'No se encontró la información solicitada.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      409 => ConflictException(
        message:
            extractedMessage ??
            'La operación entra en conflicto con información existente.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      422 => ValidationException(
        message:
            extractedMessage ?? 'Algunos datos no pudieron ser procesados.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      >= 500 => ServerException(
        message:
            extractedMessage ??
            'Ocurrió un problema en el servidor. Intenta nuevamente.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
      _ => ApiException(
        message: extractedMessage ?? 'Ocurrió un error inesperado.',
        statusCode: statusCode,
        details: details,
        cause: exception,
      ),
    };
  }

  static String? _extractMessage(Object? data) {
    if (data == null) {
      return null;
    }

    if (data is String) {
      final value = data.trim();
      return value.isEmpty ? null : value;
    }

    if (data is Map) {
      for (final key in const ['message', 'detail', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    return null;
  }

  static Object? _extractDetails(Object? data) {
    if (data is! Map) {
      return null;
    }

    for (final key in const ['errors', 'validation_errors', 'details']) {
      final value = data[key];
      if (value != null) {
        return value;
      }
    }

    return null;
  }
}
