import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride_offer.dart';
import '../entities/ride_offer_filters.dart';
import '../entities/zone.dart';

abstract class RideOffersRepository {
  Future<Either<Failure, List<RideOffer>>> getRideOffers({
    required RideOfferFilters filters,
  });

  Future<Either<Failure, List<Zone>>> getZones();
}
