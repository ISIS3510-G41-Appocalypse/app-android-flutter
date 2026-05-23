import '../../../../../core/storage/session_storage.dart';
import '../../../../../core/storage/signup_form_local_storage.dart';
import 'auth_datasource_local.dart';

class AuthDataSourceLocalStorage implements AuthDataSourceLocal {
  final SessionStorage sessionStorage;
  final SignupFormLocalStorage signupFormLocalStorage;

  AuthDataSourceLocalStorage({
    required this.sessionStorage,
    required this.signupFormLocalStorage,
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
  Future<void> saveSignupDraft(Map<String, dynamic> formData) {
    return signupFormLocalStorage.saveDraft(formData);
  }

  @override
  Map<String, dynamic>? getSignupDraft() {
    return signupFormLocalStorage.getDraft();
  }

  @override
  Future<void> clearSignupDraft() {
    return signupFormLocalStorage.clearDraft();
  }

  @override
  bool hasSignupDraft() {
    return signupFormLocalStorage.hasDraft();
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
