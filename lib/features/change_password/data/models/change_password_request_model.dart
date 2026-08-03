class ChangePasswordRequestModel {
  const ChangePasswordRequestModel({required this.password});

  final String password;

  Map<String, Object?> toJson() {
    return {'password': password};
  }
}
