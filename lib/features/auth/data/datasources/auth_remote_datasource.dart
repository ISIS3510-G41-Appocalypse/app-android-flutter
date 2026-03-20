import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> refreshSession({
    required String refreshToken,
  });

  Future<UserModel> getUserByAuthId({
    required AuthResponseModel authResponse,
  });
}