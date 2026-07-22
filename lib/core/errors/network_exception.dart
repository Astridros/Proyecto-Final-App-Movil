import 'app_exception.dart';

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
