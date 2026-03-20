import '../models/ride_offer_filters_request_model.dart';
import '../models/ride_offer_model.dart';

abstract class RideOffersRemoteDataSource {
  Future<List<RideOfferModel>> getRideOffers({
    required RideOfferFiltersRequestModel filters,
  });
}
