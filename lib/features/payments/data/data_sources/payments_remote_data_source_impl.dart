import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import 'payments_remote_data_source.dart';

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  static const String _paymentsPath = '/rest/v1/payments';

  final Dio dio;

  PaymentsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getDriverRidesWithPayments({
    required int driverId,
  }) {
    return _rpcRows('get_driver_rides_with_payments', {
      'p_driver_id': driverId,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getDriverPaymentsForRide({
    required int driverId,
    required String rideId,
  }) {
    return _rpcRows('get_driver_payments', {
      'p_driver_id': driverId,
      'r_id': int.tryParse(rideId) ?? rideId,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getRiderRidesWithPayments({
    required int riderId,
  }) {
    return _rpcRows('get_rider_rides_with_payments', {'p_rider_id': riderId});
  }

  @override
  Future<List<Map<String, dynamic>>> getRiderPaymentsForRide({
    required int riderId,
    required String rideId,
  }) {
    return _rpcRows('get_rider_payments', {
      'p_rider_id': riderId,
      'r_id': int.tryParse(rideId) ?? rideId,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsByReservationIds({
    required List<String> reservationIds,
  }) {
    if (reservationIds.isEmpty) {
      return Future.value(const []);
    }

    return _getRows(_paymentsPath, {
      'select': 'id,reservation_id',
      'reservation_id': 'in.(${reservationIds.join(',')})',
    });
  }

  @override
  Future<void> createPayment({
    required String reservationId,
    required int amount,
    required int driverId,
    required int riderId,
    required String type,
    required DateTime deadline,
  }) async {
    try {
      await dio.post(
        _paymentsPath,
        data: {
          'reservation_id': int.tryParse(reservationId) ?? reservationId,
          'amount': amount,
          'deadline': deadline.toIso8601String(),
          'driver_id': driverId,
          'rider_id': riderId,
          'state': 'PENDIENTE',
          'type': type,
        },
        options: Options(headers: {'Prefer': 'return=minimal'}),
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al crear el pago');
    }
  }

  @override
  Future<void> updatePayment({
    required int paymentId,
    required String state,
    String? type,
  }) async {
    final data = <String, dynamic>{'state': state};
    if (type != null) {
      data['type'] = type;
    }

    try {
      await dio.patch(
        _paymentsPath,
        data: data,
        options: Options(headers: {'Prefer': 'return=minimal'}),
        queryParameters: {'id': 'eq.$paymentId'},
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al actualizar el pago');
    }
  }

  Future<List<Map<String, dynamic>>> _getRows(
    String path,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      final data = response.data;

      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw ServerException('Formato de respuesta invalido');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar datos');
    }
  }

  Future<List<Map<String, dynamic>>> _rpcRows(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.post('/rest/v1/rpc/$functionName', data: body);
      final data = response.data;

      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw ServerException('Formato de respuesta invalido para $functionName');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al ejecutar $functionName');
    }
  }
}
