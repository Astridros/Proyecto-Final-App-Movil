import '../../domain/repositories/change_password_repository.dart';
import '../datasources/change_password_remote_datasource.dart';
import '../models/change_password_request_model.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  const ChangePasswordRepositoryImpl(this._remoteDataSource);

  final ChangePasswordRemoteDataSource _remoteDataSource;

  @override
  Future<void> changePassword({required String password}) {
    return _remoteDataSource.changePassword(
      ChangePasswordRequestModel(password: password),
    );
  }
}
