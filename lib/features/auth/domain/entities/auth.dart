import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  final String authId;
  final String email;

  const Auth({
    required this.authId,
    required this.email,
  });

  @override
  List<Object?> get props => [
        authId,
        email,
      ];
}
