abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final Object? details;
  final Object? cause;

  @override
  String toString() => message;
}
