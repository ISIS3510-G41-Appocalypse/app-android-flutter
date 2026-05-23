import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/ride_payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../data_sources/payments_remote_data_source.dart';
import '../../domain/entities/payment_method.dart';
import '../models/ride_payment_model.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  PaymentsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, List<RidePayment>>> getRiderPayments({
    required int? riderId,
  }) async {
    if (riderId == null) {
      return const Right([]);
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure('No tienes internet. No pudimos cargar tus pagos.'),
      );
    }

    try {
      final rideRows = await remoteDataSource.getRiderRidesWithPayments(
        riderId: riderId,
      );
      return Right(await _buildRiderPayments(riderId, rideRows));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al cargar tus pagos'));
    }
  }

  @override
  Future<Either<Failure, List<RidePayment>>> getDriverPayments({
    required int? driverId,
  }) async {
    if (driverId == null) {
      return const Right([]);
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure('No tienes internet. No pudimos cargar tus pagos.'),
      );
    }

    try {
      final rideRows = await remoteDataSource.getDriverRidesWithPayments(
        driverId: driverId,
      );
      return Right(await _buildDriverPayments(driverId, rideRows));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al cargar tus pagos'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasBlockingPayments({
    required int? riderId,
  }) async {
    if (riderId == null) {
      return const Right(false);
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. No pudimos validar tus pagos pendientes.',
        ),
      );
    }

    try {
      final rideRows = await remoteDataSource.getRiderRidesWithPayments(
        riderId: riderId,
      );

      for (final rideRow in rideRows) {
        final rows = await remoteDataSource.getRiderPaymentsForRide(
          riderId: riderId,
          rideId: rideRow['id'].toString(),
        );
        final hasBlocking = rows.any((row) {
          final state = row['state']?.toString();
          return state == 'PENDIENTE' || state == 'POR CONFIRMAR';
        });
        if (hasBlocking) {
          return const Right(true);
        }
      }

      return const Right(false);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al validar pagos'));
    }
  }

  @override
  Future<Either<Failure, void>> createPendingPaymentsForRide({
    required String rideId,
    required int driverId,
    required int amount,
    required List<({String reservationId, int riderId})> passengers,
  }) async {
    if (passengers.isEmpty) {
      return const Right(null);
    }

    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure('No tienes internet. No pudimos generar los pagos.'),
      );
    }

    try {
      final reservationIds = passengers
          .map((passenger) => passenger.reservationId)
          .toList();
      final existingRows = await remoteDataSource.getPaymentsByReservationIds(
        reservationIds: reservationIds,
      );
      final existingReservationIds = existingRows
          .map((row) => row['reservation_id'].toString())
          .toSet();

      for (final passenger in passengers) {
        if (existingReservationIds.contains(passenger.reservationId)) {
          continue;
        }

        await remoteDataSource.createPayment(
          reservationId: passenger.reservationId,
          amount: amount,
          driverId: driverId,
          riderId: passenger.riderId,
          type: 'CASH',
          deadline: DateTime.now().add(const Duration(days: 7)),
        );
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al generar pagos'));
    }
  }

  @override
  Future<Either<Failure, void>> markPaymentForConfirmation({
    required int paymentId,
    required String paymentType,
  }) {
    return _updatePayment(
      paymentId: paymentId,
      state: 'POR CONFIRMAR',
      type: paymentType,
      failureMessage: 'No pudimos marcar el pago como realizado.',
    );
  }

  @override
  Future<Either<Failure, void>> confirmPayment({required int paymentId}) {
    return _updatePayment(
      paymentId: paymentId,
      state: 'COMPLETADO',
      failureMessage: 'No pudimos confirmar el pago.',
    );
  }

  @override
  Future<Either<Failure, void>> rejectPayment({required int paymentId}) {
    return _updatePayment(
      paymentId: paymentId,
      state: 'PENDIENTE',
      failureMessage: 'No pudimos rechazar la confirmacion del pago.',
    );
  }

  Future<Either<Failure, void>> _updatePayment({
    required int paymentId,
    required String state,
    String? type,
    required String failureMessage,
  }) async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure('No tienes internet. Esta accion requiere conexion.'),
      );
    }

    try {
      await remoteDataSource.updatePayment(
        paymentId: paymentId,
        state: state,
        type: type,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure(failureMessage));
    }
  }

  Future<List<RidePayment>> _buildDriverPayments(
    int driverId,
    List<Map<String, dynamic>> rideRows,
  ) async {
    final payments = <RidePayment>[];

    for (final rideRow in rideRows) {
      final paymentRows = await remoteDataSource.getDriverPaymentsForRide(
        driverId: driverId,
        rideId: rideRow['id'].toString(),
      );

      for (final paymentRow in paymentRows) {
        payments.add(
          RidePaymentModel.fromRpc(
            paymentRow: paymentRow,
            rideRow: rideRow,
            driverId: driverId,
            riderId: _toInt(paymentRow['rider_id']),
            driverName: 'Conductor',
            riderName: _nameFromRow(paymentRow, fallback: 'Pasajero'),
            availableMethods: const [],
          ),
        );
      }
    }

    return payments;
  }

  Future<List<RidePayment>> _buildRiderPayments(
    int riderId,
    List<Map<String, dynamic>> rideRows,
  ) async {
    final payments = <RidePayment>[];

    for (final rideRow in rideRows) {
      final paymentRows = await remoteDataSource.getRiderPaymentsForRide(
        riderId: riderId,
        rideId: rideRow['id'].toString(),
      );

      for (final paymentRow in paymentRows) {
        final methods = _paymentMethodsFromRpc(paymentRow);
        payments.add(
          RidePaymentModel.fromRpc(
            paymentRow: paymentRow,
            rideRow: rideRow,
            driverId: _toInt(paymentRow['driver_id']),
            riderId: riderId,
            driverName: _nameFromRow(paymentRow, fallback: 'Conductor'),
            riderName: 'Pasajero',
            availableMethods: methods,
          ),
        );
      }
    }

    return payments;
  }

  String _nameFromRow(Map<String, dynamic> row, {required String fallback}) {
    final firstName = row['first_name']?.toString().trim() ?? '';
    final lastName = row['last_name']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? fallback : fullName;
  }

  List<PaymentMethod> _paymentMethodsFromRpc(Map<String, dynamic> row) {
    final rawMethods = row['payment_methods'];
    if (rawMethods is! List) {
      return const [];
    }

    return rawMethods
        .map((rawMethod) {
          if (rawMethod is! Map) {
            return const PaymentMethod(id: 0, driverId: 0, type: '');
          }

          final method = Map<String, dynamic>.from(rawMethod);
          return PaymentMethod(
            id: _toInt(method['id']),
            driverId: _toInt(row['driver_id']),
            type: method['method_name']?.toString() ?? '',
            numberAccount: method['number_account']?.toString(),
          );
        })
        .where((method) => method.type.isNotEmpty)
        .toList();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
