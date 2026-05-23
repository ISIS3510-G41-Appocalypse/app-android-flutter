import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../domain/entities/ride_payment.dart';
import '../../domain/usecases/confirm_payment.dart';
import '../../domain/usecases/get_driver_payments.dart';
import '../../domain/usecases/get_rider_payments.dart';
import '../../domain/usecases/mark_payment_for_confirmation.dart';
import '../../domain/usecases/reject_payment.dart';
import 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  static const Duration _offlineRetryInterval = Duration(seconds: 5);

  final GetDriverPayments getDriverPayments;
  final GetRiderPayments getRiderPayments;
  final MarkPaymentForConfirmation markPaymentForConfirmation;
  final ConfirmPayment confirmPaymentUseCase;
  final RejectPayment rejectPaymentUseCase;
  final LocalNotificationService localNotificationService;
  final NetworkChecker networkChecker;
  int? _lastDriverId;
  int? _lastRiderId;
  final Map<int, String> _knownDriverPaymentStates = {};
  final Map<int, String> _knownRiderPaymentStates = {};
  bool _driverPaymentsSeenOnce = false;
  bool _riderPaymentsSeenOnce = false;
  Timer? _offlineRetryTimer;
  StreamSubscription<bool>? _networkSubscription;
  bool _isOfflineRetryRunning = false;
  bool _isConnectivityRefreshRunning = false;

  PaymentsCubit({
    required this.getDriverPayments,
    required this.getRiderPayments,
    required this.markPaymentForConfirmation,
    required this.confirmPaymentUseCase,
    required this.rejectPaymentUseCase,
    required this.localNotificationService,
    required this.networkChecker,
  }) : super(PaymentsState.initial()) {
    _networkSubscription = networkChecker.onInternetStatusChange.listen(
      _handleInternetStatusChanged,
    );
  }

  Future<void> load({
    required int? driverId,
    required int? riderId,
    PaymentsRole? preferredRole,
  }) async {
    _lastDriverId = driverId;
    _lastRiderId = riderId;
    final selectedRole = preferredRole ?? state.selectedRole;
    final hasCurrentData = state.visiblePayments.isNotEmpty;
    emit(
      state.copyWith(
        status: hasCurrentData ? state.status : PaymentsStatus.loading,
        selectedRole: selectedRole,
        clearMessage: true,
        isOffline: false,
        isRefreshing: hasCurrentData,
      ),
    );

    final driverResult = await getDriverPayments(driverId: driverId);
    final riderResult = await getRiderPayments(riderId: riderId);

    Failure? driverFailure;
    Failure? riderFailure;
    List<RidePayment> driverPayments = const [];
    List<RidePayment> riderPayments = const [];
    var driverIsFromCache = false;
    var riderIsFromCache = false;

    driverResult.fold((value) => driverFailure = value, (value) {
      driverPayments = value.payments;
      driverIsFromCache = value.isFromCache;
    });
    riderResult.fold((value) => riderFailure = value, (value) {
      riderPayments = value.payments;
      riderIsFromCache = value.isFromCache;
    });

    final failure = selectedRole == PaymentsRole.driver
        ? driverFailure
        : riderFailure;
    final visibleIsFromCache = selectedRole == PaymentsRole.driver
        ? driverIsFromCache
        : riderIsFromCache;
    if (failure != null) {
      if (failure is NetworkFailure) {
        _startOfflineRetry();
      } else {
        _stopOfflineRetry();
      }

      emit(
        state.copyWith(
          status: PaymentsStatus.error,
          message: failure.message,
          isOffline: failure is NetworkFailure,
          isRefreshing: false,
        ),
      );
      return;
    }

    final selectedMethods = <int, String>{
      for (final payment in riderPayments)
        if (payment.type != null && payment.type!.isNotEmpty)
          payment.id: payment.type!,
    };
    final visiblePayments = selectedRole == PaymentsRole.driver
        ? driverPayments
        : riderPayments;
    if (!visibleIsFromCache) {
      _stopOfflineRetry();
      _notifyIncomingPaymentChanges(
        driverPayments: driverPayments,
        riderPayments: riderPayments,
      );
    } else {
      _startOfflineRetry();
    }

    emit(
      state.copyWith(
        status: visiblePayments.isEmpty
            ? PaymentsStatus.empty
            : PaymentsStatus.success,
        selectedRole: selectedRole,
        driverPayments: driverPayments,
        riderPayments: riderPayments,
        selectedMethodByPaymentId: selectedMethods,
        message: visibleIsFromCache
            ? 'Sin conexion. Mostrando la ultima informacion disponible.'
            : null,
        clearMessage: !visibleIsFromCache,
        isOffline: visibleIsFromCache,
        isRefreshing: false,
      ),
    );
  }

  void changeRole(PaymentsRole role) {
    final visiblePayments = role == PaymentsRole.driver
        ? state.driverPayments
        : state.riderPayments;
    emit(
      state.copyWith(
        selectedRole: role,
        status: visiblePayments.isEmpty
            ? PaymentsStatus.empty
            : PaymentsStatus.success,
        clearMessage: true,
        isRefreshing: false,
      ),
    );
  }

  void selectMethod({required int paymentId, required String type}) {
    emit(
      state.copyWith(
        selectedMethodByPaymentId: {
          ...state.selectedMethodByPaymentId,
          paymentId: type,
        },
      ),
    );
  }

  Future<void> submitPassengerPayment(RidePayment payment) async {
    final method = state.selectedMethodByPaymentId[payment.id];
    if (method == null || method.isEmpty) {
      emit(state.copyWith(message: 'Selecciona un metodo de pago.'));
      return;
    }

    await _runPaymentAction(
      payment: payment,
      successMessage: 'Pago enviado para confirmacion.',
      action: () => markPaymentForConfirmation(
        paymentId: payment.id,
        paymentType: method,
      ),
    );
  }

  Future<void> confirmPayment(RidePayment payment) {
    return _runPaymentAction(
      payment: payment,
      successMessage: 'Pago confirmado.',
      action: () => confirmPaymentUseCase(paymentId: payment.id),
    );
  }

  Future<void> rejectPayment(RidePayment payment) {
    return _runPaymentAction(
      payment: payment,
      successMessage: 'Pago devuelto a pendiente.',
      action: () => rejectPaymentUseCase(paymentId: payment.id),
    );
  }

  Future<void> _runPaymentAction({
    required RidePayment payment,
    required String successMessage,
    required Future<Either<Failure, void>> Function() action,
  }) async {
    if (state.isUpdating) {
      return;
    }

    if (state.isOffline) {
      emit(
        state.copyWith(
          message: 'Necesitas conexion para actualizar el estado del pago.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isUpdating: true,
        updatingPaymentId: payment.id,
        clearMessage: true,
        isOffline: false,
        isRefreshing: false,
      ),
    );

    final result = await action();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isUpdating: false,
            clearUpdatingPaymentId: true,
            message: failure.message,
            isOffline: failure is NetworkFailure,
            isRefreshing: false,
          ),
        );
      },
      (_) async {
        emit(
          state.copyWith(
            isUpdating: false,
            clearUpdatingPaymentId: true,
            message: successMessage,
            isOffline: false,
            isRefreshing: false,
          ),
        );
        await load(
          driverId: _lastDriverId,
          riderId: _lastRiderId,
          preferredRole: state.selectedRole,
        );
      },
    );
  }

  void _notifyIncomingPaymentChanges({
    required List<RidePayment> driverPayments,
    required List<RidePayment> riderPayments,
  }) {
    if (_driverPaymentsSeenOnce) {
      for (final payment in driverPayments) {
        final previousState = _knownDriverPaymentStates[payment.id];
        if (previousState != 'POR CONFIRMAR' &&
            payment.state == 'POR CONFIRMAR') {
          unawaited(
            localNotificationService.showPassengerPaymentSubmittedNotification(
              paymentId: payment.id,
              riderName: payment.riderName,
              rideLabel: '${payment.source} -> ${payment.destination}',
              amount: payment.amount,
              method: payment.type ?? 'Metodo no especificado',
            ),
          );
        }
      }
    }

    if (_riderPaymentsSeenOnce) {
      for (final payment in riderPayments) {
        final previousState = _knownRiderPaymentStates[payment.id];
        if (previousState == 'POR CONFIRMAR' && payment.state == 'COMPLETADO') {
          unawaited(
            localNotificationService.showPaymentConfirmedNotification(
              paymentId: payment.id,
              driverName: payment.driverName,
              amount: payment.amount,
            ),
          );
        } else if (previousState == 'POR CONFIRMAR' &&
            payment.state == 'PENDIENTE') {
          unawaited(
            localNotificationService.showPaymentRejectedNotification(
              paymentId: payment.id,
              driverName: payment.driverName,
              amount: payment.amount,
            ),
          );
        }
      }
    }

    _knownDriverPaymentStates
      ..clear()
      ..addEntries(
        driverPayments.map((payment) => MapEntry(payment.id, payment.state)),
      );
    _knownRiderPaymentStates
      ..clear()
      ..addEntries(
        riderPayments.map((payment) => MapEntry(payment.id, payment.state)),
      );
    _driverPaymentsSeenOnce = true;
    _riderPaymentsSeenOnce = true;
  }

  void _startOfflineRetry() {
    if (_offlineRetryTimer != null) {
      return;
    }

    _offlineRetryTimer = Timer.periodic(_offlineRetryInterval, (_) async {
      if (_isOfflineRetryRunning || isClosed) {
        return;
      }

      final hasInternet = await networkChecker.hasInternet;
      if (!hasInternet) {
        return;
      }

      _isOfflineRetryRunning = true;
      try {
        await load(
          driverId: _lastDriverId,
          riderId: _lastRiderId,
          preferredRole: state.selectedRole,
        );
      } finally {
        _isOfflineRetryRunning = false;
      }
    });
  }

  void _stopOfflineRetry() {
    _offlineRetryTimer?.cancel();
    _offlineRetryTimer = null;
    _isOfflineRetryRunning = false;
  }

  Future<void> _handleInternetStatusChanged(bool hasInternet) async {
    if (isClosed) {
      return;
    }

    if (!hasInternet) {
      if (state.visiblePayments.isNotEmpty) {
        emit(
          state.copyWith(
            message:
                'Sin conexion. Mostrando la ultima informacion disponible.',
            isOffline: true,
            isRefreshing: false,
          ),
        );
        _startOfflineRetry();
      }
      return;
    }

    if (_isConnectivityRefreshRunning) {
      return;
    }

    _stopOfflineRetry();
    if (state.isOffline) {
      emit(
        state.copyWith(
          clearMessage: true,
          isOffline: false,
          isRefreshing: state.visiblePayments.isNotEmpty,
        ),
      );
    }

    _isConnectivityRefreshRunning = true;
    try {
      await load(
        driverId: _lastDriverId,
        riderId: _lastRiderId,
        preferredRole: state.selectedRole,
      );
    } finally {
      _isConnectivityRefreshRunning = false;
    }
  }

  @override
  Future<void> close() {
    _stopOfflineRetry();
    _networkSubscription?.cancel();
    return super.close();
  }
}
