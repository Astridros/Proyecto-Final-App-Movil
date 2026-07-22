import 'app_exception.dart';

class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.details,
    super.cause,
  });
}
