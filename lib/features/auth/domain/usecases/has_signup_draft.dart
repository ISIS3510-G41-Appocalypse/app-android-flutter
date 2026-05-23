import '../repositories/auth_repository.dart';

class HasSignupDraft {
  final AuthRepository repository;

  HasSignupDraft(this.repository);

  bool call() {
    return repository.hasSignupDraft();
  }
}
