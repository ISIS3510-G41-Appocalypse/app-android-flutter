import 'package:dio/dio.dart';
import '../models/ride_offer_filters_request_model.dart';
import '../models/ride_offer_model.dart';

abstract class RideOffersRemoteDataSource {
  Future<List<RideOfferModel>> getRideOffers({
    required RideOfferFiltersRequestModel filters,
  });
}

class RideOffersRemoteDataSourceImpl implements RideOffersRemoteDataSource {
  static const String _rideOffersPath = '/ride_offers';

  final Dio dio;

  RideOffersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RideOfferModel>> getRideOffers({
    required RideOfferFiltersRequestModel filters,
  }) async {
    try {
      final response = await dio.get(
        _rideOffersPath,
        queryParameters: filters.toQueryParameters(),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => RideOfferModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      if (data is Map<String, dynamic> && data['data'] is List) {
        final items = data['data'] as List<dynamic>;
        return items
            .map(
              (item) => RideOfferModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      throw Exception('Formato de respuesta invalido');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        throw Exception('No autorizado para consultar ofertas');
      }

      if (statusCode == 500) {
        throw Exception('Error interno del servidor');
      }

      throw Exception('No fue posible cargar las ofertas de viaje');
    }
  }
}
