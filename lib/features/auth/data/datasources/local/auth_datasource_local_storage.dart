import '../../../../../core/storage/token_storage.dart';
import 'auth_datasource_local.dart';

class AuthDataSourceLocalStorage implements AuthDataSourceLocal {
  final TokenStorage tokenStorage;

  AuthDataSourceLocalStorage({
    required this.tokenStorage,
  });

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) {
    return tokenStorage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<({String accessToken, String refreshToken})?> getSession() {
    return tokenStorage.getSession();
  }

  @override
  Future<void> clearSession() {
    return tokenStorage.clearSession();
  }

  @override
  Future<bool> hasSession() {
    return tokenStorage.hasSession();
  }
}
