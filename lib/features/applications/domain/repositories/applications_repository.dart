import '../entities/application.dart';

abstract class ApplicationsRepository {
  Future<List<Application>> getMyApplications();

  Future<List<Application>> getOfferApplications(
      String offerId,
      );

  Future<Application> updateApplication({
    required String applicationId,
    int? rating,
    String? status,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  });
}