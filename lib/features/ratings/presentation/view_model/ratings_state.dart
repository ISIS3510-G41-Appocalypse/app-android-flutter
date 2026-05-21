enum RatingsStatus { initial, submitting, success, error }

class RatingsState {
  final RatingsStatus status;
  final String? message;

  const RatingsState({required this.status, this.message});

  factory RatingsState.initial() {
    return const RatingsState(status: RatingsStatus.initial);
  }

  RatingsState copyWith({RatingsStatus? status, Object? message = _sentinel}) {
    return RatingsState(
      status: status ?? this.status,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
    );
  }

  static const Object _sentinel = Object();
}
