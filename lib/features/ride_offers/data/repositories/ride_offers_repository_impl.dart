import '../../domain/entities/ride_offer.dart';
import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/repositories/ride_offers_repository.dart';
import '../data_sources/ride_offers_remote_datasource.dart';
import '../models/ride_offer_filters_request_model.dart';

class RideOffersRepositoryImpl implements RideOffersRepository {
  final RideOffersRemoteDataSource remoteDataSource;

  RideOffersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RideOffer>> getRideOffers({
    required RideOfferFilters filters,
  }) async {
    final requestModel = RideOfferFiltersRequestModel.fromEntity(filters);
    final models = await remoteDataSource.getRideOffers(filters: requestModel);

    return models.map((model) => model.toEntity()).toList();
  }
}
