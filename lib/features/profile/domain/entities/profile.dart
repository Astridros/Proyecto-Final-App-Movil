import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.email,
    required this.profileCompleted,
    this.firstName,
    this.lastName,
    this.nombre,
    this.referralMatricula,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.birthDate,
    this.cedula,
    this.gender,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nombre;
  final String? referralMatricula;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? birthDate;
  final String? cedula;
  final String? gender;
  final bool profileCompleted;

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    nombre,
    referralMatricula,
    role,
    createdAt,
    updatedAt,
    lastLoginAt,
    birthDate,
    cedula,
    gender,
    profileCompleted,
  ];
}
