import 'package:equatable/equatable.dart';
import '../../domain/entities/auth.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final Auth? auth;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.auth,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Auth? auth,
    String? errorMessage,
    bool clearAuth = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      auth: clearAuth ? null : (auth ?? this.auth),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        auth,
        errorMessage,
      ];
}
