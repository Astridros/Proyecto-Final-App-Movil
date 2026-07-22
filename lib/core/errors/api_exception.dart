import 'app_exception.dart';

class ApiException extends AppException {
  const ApiException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
