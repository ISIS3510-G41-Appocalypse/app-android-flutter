import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/rate_driver_model.dart';
import '../models/rate_rider_model.dart';
import 'ratings_remote_data_source.dart';

class RatingsRemoteDataSourceImpl implements RatingsRemoteDataSource {
  static const String _ratesDriverPath = '/rest/v1/rates_driver';
  static const String _ratesRiderPath = '/rest/v1/rates_rider';

  final Dio dio;

  RatingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> submitDriverRating(RateDriverModel rating) async {
    try {
      await dio.post(
        _ratesDriverPath,
        data: rating.toJson(),
        options: Options(headers: {'Prefer': 'return=minimal'}),
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al calificar al conductor');
    }
  }

  @override
  Future<void> submitRiderRatings(List<RateRiderModel> ratings) async {
    if (ratings.isEmpty) {
      return;
    }

    try {
      await dio.post(
        _ratesRiderPath,
        data: ratings.map((rating) => rating.toJson()).toList(),
        options: Options(headers: {'Prefer': 'return=minimal'}),
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getErrorMessage(e));
    } catch (_) {
      throw ServerException('Error inesperado al calificar pasajeros');
    }
  }
}
