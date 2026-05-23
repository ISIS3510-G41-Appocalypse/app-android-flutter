import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../ride_offers/domain/entities/zone.dart';
import '../repositories/auth_repository.dart';

class GetRegisterZones {
  final AuthRepository repository;

  GetRegisterZones(this.repository);

  Future<Either<Failure, List<Zone>>> call() {
    return repository.getZones();
  }
}
