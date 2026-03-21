import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/zone.dart';
import '../repositories/ride_offers_repository.dart';

class GetZones {
  final RideOffersRepository repository;

  GetZones(this.repository);

  Future<Either<Failure, List<Zone>>> call() {
    return repository.getZones();
  }
}
