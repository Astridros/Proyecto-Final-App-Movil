import 'api_exception.dart';

class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
