class ApiConstants {
  const ApiConstants._();

  static const acceptHeader = 'Accept';
  static const contentTypeHeader = 'Content-Type';
  static const authorizationHeader = 'Authorization';
  static const jsonContentType = 'application/json';

  static const connectTimeout = Duration(seconds: 20);
  static const sendTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 30);
}
