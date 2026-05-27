import '../../models/user_model.dart';

abstract class UserDataSourceLocal {
  Future<void> initialize();

  Future<void> saveUser({
    required UserModel user,
  });

  UserModel? getUser({
    required String authId,
  });

  Future<void> clearUser({
    required String authId,
  });
}
