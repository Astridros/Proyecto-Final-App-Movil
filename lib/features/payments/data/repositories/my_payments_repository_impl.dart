import '../../domain/entities/payment.dart';
import '../../domain/repositories/my_payments_repository.dart';
import '../datasources/my_payments_remote_datasource.dart';

class MyPaymentsRepositoryImpl implements MyPaymentsRepository {
  const MyPaymentsRepositoryImpl(this._remoteDataSource);

  final MyPaymentsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Payment>> getMyPayments() {
    return _remoteDataSource.getMyPayments();
  }
}
