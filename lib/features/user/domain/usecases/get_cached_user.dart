import '../../../auth/domain/entities/auth.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetCachedUser {
  final UserRepository repository;

  GetCachedUser(this.repository);

  User? call({required Auth auth}) {
    return repository.getCachedUser(auth: auth);
  }
}
