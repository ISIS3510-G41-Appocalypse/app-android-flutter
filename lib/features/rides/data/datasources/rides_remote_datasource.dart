import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_plus/dio_cache_plus.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/performance/performance_features.dart';
import '../../../../core/performance/performance_time_tracker.dart';
import '../models/vehicle_model.dart';
import '../models/ride_model.dart';
import '../models/zone_model.dart';

class RidesRemoteDatasource {
  final DioClient dioClient;
  final PerformanceTimeTracker performanceTimeTracker;

  RidesRemoteDatasource({
    required DioClient client,
    required this.performanceTimeTracker,
  }) : dioClient = client;

  Future<List<VehicleModel>> getVehiclesByDriver(int driverId) async {
    final response = await dioClient.dio.get(
      '/rest/v1/vehicles',
      queryParameters: {'driver_id': 'eq.$driverId'},
      options: Options().setCaching(enableCache: true),
    );
    return (response.data as List)
        .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RideModel> createRide(RideModel ride) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await dioClient.dio.post(
        '/rest/v1/rides',
        data: ride.toJson(),
        options: Options(headers: {'Prefer': 'return=representation'}),
      );
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.createRide,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.backEnd,
        ),
      );

      return RideModel.fromJson((response.data as List).first);
    } on DioException {
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.createRide,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.backEnd,
        ),
      );

      rethrow;
    }
  }

  Future<int> getDriverIdByUserId(int userId) async {
    final response = await dioClient.dio.get(
      '/rest/v1/drivers',
      queryParameters: {'user_id': 'eq.$userId'},
    );
    final data = response.data as List;
    if (data.isEmpty) throw Exception('No eres conductor todavía');
    return data.first['id'] as int;
  }

  Future<List<ZoneModel>> getZones() async {
    final response = await dioClient.dio.get(
      '/rest/v1/zones',
      options: Options().setCaching(enableCache: true),
    );
    return (response.data as List)
        .map((json) => ZoneModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
