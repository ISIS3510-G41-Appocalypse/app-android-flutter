import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../domain/entities/ride_payment.dart';
import '../../domain/usecases/confirm_payment.dart';
import '../../domain/usecases/get_driver_payments.dart';
import '../../domain/usecases/get_rider_payments.dart';
import '../../domain/usecases/mark_payment_for_confirmation.dart';
import '../../domain/usecases/reject_payment.dart';
import 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final GetDriverPayments getDriverPayments;
  final GetRiderPayments getRiderPayments;
  final MarkPaymentForConfirmation markPaymentForConfirmation;
  final ConfirmPayment confirmPaymentUseCase;
  final RejectPayment rejectPaymentUseCase;
  final LocalNotificationService localNotificationService;
  int? _lastDriverId;
  int? _lastRiderId;
  final Map<int, String> _knownDriverPaymentStates = {};
  final Map<int, String> _knownRiderPaymentStates = {};
  bool _driverPaymentsSeenOnce = false;
  bool _riderPaymentsSeenOnce = false;

  PaymentsCubit({
    required this.getDriverPayments,
    required this.getRiderPayments,
    required this.markPaymentForConfirmation,
    required this.confirmPaymentUseCase,
    required this.rejectPaymentUseCase,
    required this.localNotificationService,
  }) : super(PaymentsState.initial());

  Future<void> load({
    required int? driverId,
    required int? riderId,
    PaymentsRole? preferredRole,
  }) async {
    _lastDriverId = driverId;
    _lastRiderId = riderId;
    emit(
      state.copyWith(
        status: PaymentsStatus.loading,
        selectedRole: preferredRole ?? state.selectedRole,
        clearMessage: true,
        isOffline: false,
      ),
    );

    final driverResult = await getDriverPayments(driverId: driverId);
    final riderResult = await getRiderPayments(riderId: riderId);

    Failure? failure;
    List<RidePayment> driverPayments = const [];
    List<RidePayment> riderPayments = const [];

    driverResult.fold((value) => failure = value, (value) {
      driverPayments = value;
    });
    riderResult.fold((value) => failure ??= value, (value) {
      riderPayments = value;
    });

    if (failure != null) {
      emit(
        state.copyWith(
          status: PaymentsStatus.error,
          message: failure!.message,
          isOffline: failure is NetworkFailure,
        ),
      );
      return;
    }

    final selectedMethods = <int, String>{
      for (final payment in riderPayments)
        if (payment.type != null && payment.type!.isNotEmpty)
          payment.id: payment.type!,
    };
    final selectedRole = preferredRole ?? state.selectedRole;
    final visiblePayments = selectedRole == PaymentsRole.driver
        ? driverPayments
        : riderPayments;
    _notifyIncomingPaymentChanges(
      driverPayments: driverPayments,
      riderPayments: riderPayments,
    );

    emit(
      state.copyWith(
        status: visiblePayments.isEmpty
            ? PaymentsStatus.empty
            : PaymentsStatus.success,
        selectedRole: selectedRole,
        driverPayments: driverPayments,
        riderPayments: riderPayments,
        selectedMethodByPaymentId: selectedMethods,
        clearMessage: true,
        isOffline: false,
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

    emit(
      state.copyWith(
        isUpdating: true,
        updatingPaymentId: payment.id,
        clearMessage: true,
        isOffline: false,
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
}
