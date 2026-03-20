import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/vehicle_model.dart';
import '../models/ride_model.dart';
import '../models/zone_model.dart';

class RidesRemoteDatasource {
  final DioClient    _client;
  final TokenStorage _tokenStorage;

  RidesRemoteDatasource({
    required DioClient    client,
    required TokenStorage tokenStorage,
  })  : _client       = client,
        _tokenStorage = tokenStorage;

  Future<List<VehicleModel>> getVehiclesByDriver(int driverId) async {
    final response = await _client.dio.get(
      '/rest/v1/vehicles',
      queryParameters: {'driver_id': 'eq.$driverId'},
    );
    return (response.data as List)
        .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RideModel> createRide(RideModel ride) async {
    final response = await _client.dio.post(
      '/rest/v1/rides',
      data: ride.toJson(),
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    return RideModel.fromJson((response.data as List).first);
  }

  Future<int> getDriverIdByUserId(int userId) async {
    final response = await _client.dio.get(
      '/rest/v1/drivers',
      queryParameters: {'user_id': 'eq.$userId'},
    );
    final data = response.data as List;
    if (data.isEmpty) throw Exception('No eres conductor todavía');
    return data.first['id'] as int;
  }

  Future<int> getUserIdFromToken() async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('No hay sesión activa');

    final payload = token.split('.')[1];
    final decoded = utf8.decode(
      base64Url.decode(base64Url.normalize(payload)),
    );
    final jsonMap = jsonDecode(decoded) as Map<String, dynamic>;
    final authId  = jsonMap['sub'] as String;

    final response = await _client.dio.get(
      '/rest/v1/users',
      queryParameters: {'auth_id': 'eq.$authId'},
    );
    final data = response.data as List;
    if (data.isEmpty) throw Exception('Usuario no encontrado');
    return data.first['id'] as int;
  }

  Future<List<ZoneModel>> getZones() async {
    final response = await _client.dio.get('/rest/v1/zones');
    return (response.data as List)
        .map((json) => ZoneModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}