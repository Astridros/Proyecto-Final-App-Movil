class UpdateProfileRequestModel {
  const UpdateProfileRequestModel({
    required this.firstName,
    required this.lastName,
    required this.cedula,
    required this.gender,
    required this.birthDate,
    this.email,
    this.referralMatricula,
  });

  final String firstName;
  final String lastName;
  final String cedula;
  final String gender;
  final DateTime birthDate;
  final String? email;
  final String? referralMatricula;

  Map<String, Object?> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'cedula': cedula,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      if (email != null) 'email': email,
      if (referralMatricula != null) 'referralMatricula': referralMatricula,
    };
  }
}
