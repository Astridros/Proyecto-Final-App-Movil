import 'api_exception.dart';

class ConflictException extends ApiException {
  const ConflictException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
