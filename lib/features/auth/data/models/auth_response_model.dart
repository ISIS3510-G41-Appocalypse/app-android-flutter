class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String authId;
  final String email;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.authId,
    required this.email,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      authId: user['id'] as String? ?? '',
      email: user['email'] as String? ?? '',
    );
  }
}