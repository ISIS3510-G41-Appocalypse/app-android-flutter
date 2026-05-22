import 'package:equatable/equatable.dart';
import '../../domain/entities/auth.dart';
import '../../../ride_offers/domain/entities/zone.dart';

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
  final List<Zone> registerZones;
  final bool isLoadingRegisterZones;
  final String? registerZonesErrorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.auth,
    this.errorMessage,
    this.registerZones = const [],
    this.isLoadingRegisterZones = false,
    this.registerZonesErrorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Auth? auth,
    String? errorMessage,
    List<Zone>? registerZones,
    bool? isLoadingRegisterZones,
    String? registerZonesErrorMessage,
    bool clearAuth = false,
    bool clearError = false,
    bool clearRegisterZonesError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      auth: clearAuth ? null : (auth ?? this.auth),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      registerZones: registerZones ?? this.registerZones,
      isLoadingRegisterZones:
          isLoadingRegisterZones ?? this.isLoadingRegisterZones,
      registerZonesErrorMessage: clearRegisterZonesError
          ? null
          : (registerZonesErrorMessage ?? this.registerZonesErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        auth,
        errorMessage,
        registerZones,
        isLoadingRegisterZones,
        registerZonesErrorMessage,
      ];
}
