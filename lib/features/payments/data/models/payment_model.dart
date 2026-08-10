import '../../domain/entities/payment.dart';

// Yeison Familia - modulo Mis Pagos.
// El parseo es tolerante a proposito: si el backend agrega, renombra o deja
// vacio un campo, la pantalla sigue mostrando el resto del pago en vez de
// romperse. Se aceptan varios nombres para el mismo dato porque el historial
// puede devolverlos con otra forma que el cobro.
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.concept,
    required super.status,
    required super.cardLast4,
    required super.reference,
    required super.createdAt,
    required super.declineReason,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _readString(json, const ['id', '_id', 'paymentId']),
      amount: _readDouble(json, const ['amount', 'total', 'monto']),
      currency: _readString(json, const ['currency', 'moneda'], fallback: 'USD'),
      concept: _readString(
        json,
        const ['concept', 'concepto', 'description'],
        fallback: 'Pago en Ocupa2',
      ),
      status: _readString(json, const ['status', 'estado']),
      cardLast4: _readString(json, const ['cardLast4', 'last4', 'cardLastFour']),
      reference: _readString(json, const ['reference', 'referencia']),
      createdAt: _readDate(json, const ['createdAt', 'created_at', 'fecha']),
      declineReason: _readNullableString(
        json,
        const ['declineReason', 'decline_reason', 'motivo'],
      ),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    return _readNullableString(json, keys) ?? fallback;
  }

  static String? _readNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }

      if (value is num) {
        return value.toString();
      }
    }

    return null;
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  static DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(value.trim());
        if (parsed != null) {
          return parsed.toLocal();
        }
      }
    }

    return null;
  }
}
