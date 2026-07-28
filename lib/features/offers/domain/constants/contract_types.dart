class ContractTypes {
  const ContractTypes._();

  // Valores exactos esperados por el backend para filtros y ofertas.
  static const temporal = 'temporal';
  static const fijo = 'fijo';
  static const horas = 'horas';

  static const values = [temporal, fijo, horas];

  static bool isValid(String value) => values.contains(value);

  static String? labelFor(String? value) {
    return switch (value) {
      temporal => 'Temporal',
      fijo => 'Fijo',
      horas => 'Por horas',
      _ => null,
    };
  }
}
