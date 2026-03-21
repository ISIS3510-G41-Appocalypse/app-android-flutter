import 'package:dio/dio.dart';
import '../models/reservation_model.dart';
import 'reservation_remote_datasource.dart';

class ReservationRemoteDataSourceSupabase implements ReservationRemoteDataSource {
  final Dio dio;

  ReservationRemoteDataSourceSupabase({required this.dio});

  @override
  Future<ReservationModel?> getActiveReservationForRider(int riderId) async {
    try {
      final response = await dio.get(
        '/rest/v1/reservations',
        queryParameters: {
          'rider_id': 'eq.$riderId',
          'state': 'in.(PENDIENTE,ACEPTADA,EN_CURSO)',
        },
      );
      final data = response.data as List<dynamic>;
      if (data.isNotEmpty) {
        return ReservationModel.fromJson(data.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
