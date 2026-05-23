enum RatingsStatus { initial, submitting, success, error }

class RatingsState {
  static const Object _sentinel = Object();

  final RatingsStatus status;
  final String? message;
  final bool isOffline;
  final bool hasDraft;
  final Map<String, dynamic>? draftData;

  const RatingsState({
    required this.status,
    this.message,
    required this.isOffline,
    required this.hasDraft,
    this.draftData,
  });

  factory RatingsState.initial() {
    return const RatingsState(
      status: RatingsStatus.initial,
      isOffline: false,
      hasDraft: false,
      draftData: null,
    );
  }

  RatingsState copyWith({
    RatingsStatus? status,
    Object? message = _sentinel,
    bool? isOffline,
    bool? hasDraft,
    Object? draftData = _sentinel,
  }) {
    return RatingsState(
      status: status ?? this.status,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
      isOffline: isOffline ?? this.isOffline,
      hasDraft: hasDraft ?? this.hasDraft,
      draftData: identical(draftData, _sentinel)
          ? this.draftData
          : draftData as Map<String, dynamic>?,
    );
  }
}
