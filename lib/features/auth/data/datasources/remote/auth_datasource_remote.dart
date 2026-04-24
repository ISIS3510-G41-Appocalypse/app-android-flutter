import '../../models/auth_model.dart';

abstract class AuthDataSourceRemote {
  Future<AuthModel> login({
    required String email,
    required String password,
  });

  Future<AuthModel> verifySession();
}
