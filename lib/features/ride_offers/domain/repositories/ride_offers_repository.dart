import '../entities/ride_offer.dart';
import '../entities/ride_offer_filters.dart';

abstract class RideOffersRepository {
  Future<List<RideOffer>> getRideOffers({required RideOfferFilters filters});
}
