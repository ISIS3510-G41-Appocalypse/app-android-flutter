import '../../domain/entities/ride_payment.dart';

enum PaymentsStatus { initial, loading, success, empty, error }

enum PaymentsRole { driver, rider }

class PaymentsState {
  final PaymentsStatus status;
  final PaymentsRole selectedRole;
  final List<RidePayment> driverPayments;
  final List<RidePayment> riderPayments;
  final Map<int, String> selectedMethodByPaymentId;
  final String? message;
  final bool isOffline;
  final bool isRefreshing;
  final bool isUpdating;
  final int? updatingPaymentId;

  const PaymentsState({
    required this.status,
    required this.selectedRole,
    required this.driverPayments,
    required this.riderPayments,
    required this.selectedMethodByPaymentId,
    this.message,
    required this.isOffline,
    required this.isRefreshing,
    required this.isUpdating,
    this.updatingPaymentId,
  });

  factory PaymentsState.initial() {
    return const PaymentsState(
      status: PaymentsStatus.initial,
      selectedRole: PaymentsRole.driver,
      driverPayments: [],
      riderPayments: [],
      selectedMethodByPaymentId: {},
      message: null,
      isOffline: false,
      isRefreshing: false,
      isUpdating: false,
      updatingPaymentId: null,
    );
  }

  List<RidePayment> get visiblePayments {
    return selectedRole == PaymentsRole.driver ? driverPayments : riderPayments;
  }

  PaymentsState copyWith({
    PaymentsStatus? status,
    PaymentsRole? selectedRole,
    List<RidePayment>? driverPayments,
    List<RidePayment>? riderPayments,
    Map<int, String>? selectedMethodByPaymentId,
    String? message,
    bool clearMessage = false,
    bool? isOffline,
    bool? isRefreshing,
    bool? isUpdating,
    int? updatingPaymentId,
    bool clearUpdatingPaymentId = false,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      driverPayments: driverPayments ?? this.driverPayments,
      riderPayments: riderPayments ?? this.riderPayments,
      selectedMethodByPaymentId:
          selectedMethodByPaymentId ?? this.selectedMethodByPaymentId,
      message: clearMessage ? null : message ?? this.message,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isUpdating: isUpdating ?? this.isUpdating,
      updatingPaymentId: clearUpdatingPaymentId
          ? null
          : updatingPaymentId ?? this.updatingPaymentId,
    );
  }
}
