import 'api_exception.dart';

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
