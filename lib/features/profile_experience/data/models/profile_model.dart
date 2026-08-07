import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.nombre,
    required super.email,
    required super.matricula,
    required super.cedula,
    required super.birthDate,
    required super.firstName,
    required super.lastName,
    required super.gender,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      matricula: json['referralMatricula'] ?? '',
      cedula: json['cedula'] ?? '',
      birthDate: json['birthDate'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "cedula": cedula,
      "gender": gender,
      "birthDate": birthDate,
    };
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      nombre: profile.nombre,
      email: profile.email,
      matricula: profile.matricula,
      cedula: profile.cedula,
      birthDate: profile.birthDate,
      firstName: profile.firstName,
      lastName: profile.lastName,
      gender: profile.gender,
    );
  }
}