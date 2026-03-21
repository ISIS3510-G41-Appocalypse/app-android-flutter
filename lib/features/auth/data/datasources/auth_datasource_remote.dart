import '../models/auth_model.dart';
import '../models/user_model.dart';

abstract class AuthDataSourceRemote {
  
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<AuthModel> refreshSession({
    required String refreshToken,
  });

  Future<UserModel> restoreSession();
}