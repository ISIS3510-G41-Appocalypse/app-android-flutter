import '../entities/ride_offer.dart';
import '../entities/ride_offer_filters.dart';
import '../repositories/ride_offers_repository.dart';

class GetRideOffers {
  final RideOffersRepository repository;

  GetRideOffers(this.repository);

  Future<List<RideOffer>> call({required RideOfferFilters filters}) {
    return repository.getRideOffers(filters: filters);
  }
}
