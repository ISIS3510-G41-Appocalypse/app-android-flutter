import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_offer.dart';
import '../entities/ride_offer_filters.dart';
import '../repositories/ride_offers_repository.dart';

class GetRideOffers {
  final RideOffersRepository repository;

  GetRideOffers(this.repository);

  Future<Either<Failure, List<RideOffer>>> call({
    required RideOfferFilters filters,
  }) {
    return repository.getRideOffers(filters: filters);
  }
}
