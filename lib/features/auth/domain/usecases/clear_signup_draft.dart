import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ClearSignupDraft {
  final AuthRepository repository;

  ClearSignupDraft(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.clearSignupDraft();
  }
}
