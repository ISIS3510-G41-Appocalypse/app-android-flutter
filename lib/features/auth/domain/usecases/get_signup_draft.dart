import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class GetSignupDraft {
  final AuthRepository repository;

  GetSignupDraft(this.repository);

  Either<Failure, Map<String, dynamic>?> call() {
    return repository.getSignupDraft();
  }
}
