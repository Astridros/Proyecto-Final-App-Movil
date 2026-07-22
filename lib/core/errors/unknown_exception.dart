import 'app_exception.dart';

class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
