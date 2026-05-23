abstract class AuthDataSourceLocal {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveSignupDraft(Map<String, dynamic> formData);

  Map<String, dynamic>? getSignupDraft();

  Future<void> clearSignupDraft();

  bool hasSignupDraft();

  Future<({String accessToken, String refreshToken})?> getSession();

  Future<void> clearSession();

  Future<bool> hasSession();
}
