import '../entities/application.dart';

abstract class ApplicationsRepository {
  Future<List<Application>> getMyApplications();
}
