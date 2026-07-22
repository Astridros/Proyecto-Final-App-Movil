import 'api_exception.dart';

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
