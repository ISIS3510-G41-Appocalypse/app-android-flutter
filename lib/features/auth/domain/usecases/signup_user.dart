import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<Either<Failure, String>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int zoneId,
    required List<String> roles,
    required List<Map<String, dynamic>> paymentMethods,
    required List<Map<String, dynamic>> vehicles,
  }) {
    return repository.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      zoneId: zoneId,
      roles: roles,
      paymentMethods: paymentMethods,
      vehicles: vehicles,
    );
  }
}
