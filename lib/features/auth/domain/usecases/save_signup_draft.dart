import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SaveSignupDraft {
  final AuthRepository repository;

  SaveSignupDraft(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> formData) {
    return repository.saveSignupDraft(formData);
  }
}
