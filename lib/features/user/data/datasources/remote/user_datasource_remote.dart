import '../../../../auth/domain/entities/auth.dart';
import '../../models/user_model.dart';

abstract class UserDataSourceRemote {
  Future<UserModel> loadUser({
    required Auth auth,
  });
}
