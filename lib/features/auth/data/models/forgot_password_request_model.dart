class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({
    required this.email,
    required this.referralMatricula,
  });

  final String email;
  final String referralMatricula;

  Map<String, Object?> toJson() {
    return {
      'email': email.trim(),
      'referralMatricula': referralMatricula.trim(),
    };
  }
}
