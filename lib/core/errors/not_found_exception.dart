import 'api_exception.dart';

class NotFoundException extends ApiException {
  const NotFoundException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
