class UpdateProfileRequestModel {
  const UpdateProfileRequestModel({
    required this.firstName,
    required this.lastName,
    required this.cedula,
    required this.gender,
    required this.birthDate,
  });

  final String firstName;
  final String lastName;
  final String cedula;
  final String gender;
  final DateTime birthDate;

  Map<String, Object?> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'cedula': cedula,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
    };
  }
}
