import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

abstract interface class MyPaymentsRemoteDataSource {
  Future<List<Payment>> getMyPayments();
}

// Yeison Familia - modulo Mis Pagos.
// Historial de pagos del usuario autenticado. El AuthInterceptor agrega el
// token, aqui no se maneja.
class MyPaymentsRemoteDataSourceImpl implements MyPaymentsRemoteDataSource {
  const MyPaymentsRemoteDataSourceImpl(this._apiClient);

  static const _myPaymentsPath = '/me/payments';

  final ApiClient _apiClient;

  @override
  Future<List<Payment>> getMyPayments() async {
    final response = await _apiClient.get<Object?>(_myPaymentsPath);

    return _parsePayments(response.data);
  }

  // La API envuelve las listas en {ok, data}, pero se acepta tambien una lista
  // pelada por si este endpoint responde distinto.
  List<Payment> _parsePayments(Object? body) {
    final rawList = _extractList(body);
    final payments = <Payment>[];

    for (final item in rawList) {
      if (item is Map) {
        payments.add(PaymentModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return List.unmodifiable(payments);
  }

  List<Object?> _extractList(Object? body) {
    if (body is List) {
      return body;
    }

    if (body is! Map) {
      throw const ApiException(
        message: 'No se pudo leer el historial de pagos.',
      );
    }

    final map = Map<String, dynamic>.from(body);

    if (map['ok'] == false) {
      throw ApiException(message: _backendMessage(map));
    }

    for (final key in const ['data', 'payments', 'items', 'results']) {
      final value = map[key];
      if (value is List) {
        return value;
      }
    }

    throw const ApiException(message: 'No se pudo leer el historial de pagos.');
  }

  String _backendMessage(Map<String, dynamic> map) {
    for (final key in const ['message', 'error', 'detail']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return 'No se pudo cargar el historial de pagos.';
  }
}
