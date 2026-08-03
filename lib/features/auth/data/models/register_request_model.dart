class RegisterRequestModel {
  const RegisterRequestModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.referralMatricula,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String referralMatricula;

  Map<String, Object?> toJson() {
    return {
      'email': email.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'password': password,
      'referralMatricula': referralMatricula.trim(),
    };
  }
}
