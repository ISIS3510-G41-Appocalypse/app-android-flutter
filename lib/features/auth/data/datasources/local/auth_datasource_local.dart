abstract class AuthDataSourceLocal {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  });

  Future<({String accessToken, String refreshToken})?> getSession();

  Future<void> clearSession();

  Future<bool> hasSession();
}
