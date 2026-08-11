class ApplicationStatuses {
  const ApplicationStatuses._();

  static const String applied = 'applied';
  static const String finalist = 'finalist';
  static const String discarded = 'discarded';
  static const String winner = 'winner';

  static String label(String status) {
    switch (status.trim().toLowerCase()) {
      case finalist:
        return 'Finalista';

      case discarded:
        return 'Descartado';

      case winner:
        return 'Ganador';

      case applied:
      default:
        return 'Aplicado';
    }
  }
}