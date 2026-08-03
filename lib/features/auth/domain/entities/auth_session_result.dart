import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/profile.dart';

class AuthSessionResult extends Equatable {
  const AuthSessionResult({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final Profile user;

  @override
  List<Object?> get props => [token, tokenType, user];
}
