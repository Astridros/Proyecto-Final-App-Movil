class Profile {
  final String id;
  final String nombre;
  final String email;
  final String matricula;
  final String cedula;
  final String birthDate;

  final String firstName;
  final String lastName;
  final String gender;

  const Profile({
    required this.id,
    required this.nombre,
    required this.email,
    required this.matricula,
    required this.cedula,
    required this.birthDate,
    required this.firstName,
    required this.lastName,
    required this.gender,
  });

  Profile copyWith({
    String? id,
    String? nombre,
    String? email,
    String? matricula,
    String? cedula,
    String? birthDate,
    String? firstName,
    String? lastName,
    String? gender,
  }) {
    return Profile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      matricula: matricula ?? this.matricula,
      cedula: cedula ?? this.cedula,
      birthDate: birthDate ?? this.birthDate,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
    );
  }
}