import '../../../../../core/storage/session_storage.dart';
import 'auth_datasource_local.dart';

class AuthDataSourceLocalStorage implements AuthDataSourceLocal {
  final SessionStorage sessionStorage;

  AuthDataSourceLocalStorage({
    required this.sessionStorage,
  });

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) {
    return sessionStorage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<({String accessToken, String refreshToken})?> getSession() {
    return sessionStorage.getSession();
  }

  @override
  Future<void> clearSession() {
    return sessionStorage.clearSession();
  }

  @override
  Future<bool> hasSession() {
    return sessionStorage.hasSession();
  }
}
