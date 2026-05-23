import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cache_plus/dio_cache_plus.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/performance/performance_features.dart';
import '../../../../../core/performance/performance_time_tracker.dart';
import '../../models/auth_model.dart';
import 'auth_datasource_remote.dart';

class AuthDataSourceRemoteSupabase implements AuthDataSourceRemote {
  final Dio dio;
  final PerformanceTimeTracker performanceTimeTracker;

  AuthDataSourceRemoteSupabase({
    required this.dio,
    required this.performanceTimeTracker,
  });

  @override
  Future<String> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int zoneId,
    required List<String> roles,
    required List<Map<String, dynamic>> paymentMethods,
    required List<Map<String, dynamic>> vehicles,
  }) async {
    try {
      final response = await dio.post(
        '/functions/v1/signup',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'zone_id': zoneId,
          'roles': roles,
          if (roles.contains('driver')) 'payment_methods': paymentMethods,
          if (roles.contains('driver')) 'vehicles': vehicles,
        },
      );

      final authId = _extractAuthId(response.data);
      if (authId != null && authId.isNotEmpty) {
        return authId;
      }

      throw ServerException('No pudimos crear tu cuenta. Intenta de nuevo.');
    } on DioException catch (e) {
      throw ServerException(_mapSignupError(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('No pudimos crear tu cuenta. Intenta de nuevo.');
    }
  }

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await dio.post(
        ApiConstants.authToken,
        queryParameters: {'grant_type': 'password'},
        data: {'email': email, 'password': password},
      );
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.login,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.backEnd,
        ),
      );

      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      stopwatch.stop();

      unawaited(
        performanceTimeTracker.track(
          feature: PerformanceFeatures.login,
          duration: stopwatch.elapsedMilliseconds.toDouble(),
          source: PerformanceSources.backEnd,
        ),
      );

      if (e.response?.statusCode == 400 &&
          e.response?.data['msg'].contains('Invalid login credentials')) {
        throw ServerException('Credenciales invalidas');
      }

      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al iniciar sesion');
    }
  }

  @override
  Future<AuthModel> verifySession() async {
    try {
      final response = await dio.get(ApiConstants.authUser);

      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['msg'].contains('token is expired')) {
        throw ServerException('La sesion expiro');
      }

      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al verificar la sesion');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getZonesRows() async {
    try {
      final response = await dio.get(
        '/rest/v1/zones',
        queryParameters: const {'select': 'id,name'},
        options: Options().setCachingWithDuration(
          enableCache: true,
          duration: const Duration(hours: 6),
        ),
      );

      final rows = _extractRows(response.data);
      if (rows != null) {
        return rows;
      }

      throw ServerException('No fue posible cargar las zonas');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Error inesperado al consultar zonas');
    }
  }

  String _mapSignupError(DioException e) {
    if (ErrorHandler.isNetworkError(e)) {
      return ErrorHandler.getErrorMessage(e);
    }

    final errorData = _extractErrorData(e.response?.data);
    final errorCode = errorData?['error_code']?.toString();

    switch (errorCode) {
      case 'USER_ALREADY_EXISTS':
        return 'Ya existe una cuenta registrada con este correo.';
      case 'VEHICLE_LICENSE_PLATE_ALREADY_EXISTS':
        return 'Ya existe un vehiculo registrado con esa placa.';
      case 'AUTH_CREATION_FAILED':
      case 'USER_PROFILE_CREATION_FAILED':
        return 'No pudimos crear tu usuario. Intenta de nuevo.';
      case 'DRIVER_PROFILE_CREATION_FAILED':
        return 'No pudimos activar tu perfil de conductor. Intenta de nuevo.';
      case 'RIDER_PROFILE_CREATION_FAILED':
        return 'No pudimos activar tu perfil de pasajero. Intenta de nuevo.';
      case 'DRIVER_PAYMENT_METHODS_CREATION_FAILED':
        return 'No pudimos registrar tus metodos de pago. Intenta de nuevo.';
      case 'DRIVER_VEHICLES_CREATION_FAILED':
        return 'No pudimos registrar tu vehiculo. Intenta de nuevo.';
      default:
        return 'No pudimos crear tu cuenta. Intenta de nuevo.';
    }
  }

  Map<String, dynamic>? _extractErrorData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    return null;
  }

  List<Map<String, dynamic>>? _extractRows(dynamic data) {
    if (data is List) {
      return data.map((item) => item as Map<String, dynamic>).toList();
    }

    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is List) {
        return nestedData.map((item) => item as Map<String, dynamic>).toList();
      }
    }

    return null;
  }
  String? _extractAuthId(dynamic data) =>
      data is Map<String, dynamic> ? data['auth_id']?.toString() : null;
}
