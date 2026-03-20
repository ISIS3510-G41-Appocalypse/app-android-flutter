import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ride_offer.dart';
import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/repositories/ride_offers_repository.dart';
import '../data_sources/ride_offers_remote_datasource.dart';
import '../models/ride_offer_model.dart';

class RideOffersRepositoryImpl implements RideOffersRepository {
  final RideOffersRemoteDataSource remoteDataSource;

  RideOffersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RideOffer>>> getRideOffers({
    required RideOfferFilters filters,
  }) async {
    try {
      final rows = await remoteDataSource.getRideOffersRows();

      final filteredRows = rows.where((row) {
        if (row['state']?.toString() != 'OFERTADO') {
          return false;
        }

        if (filters.zoneId != null &&
            row['zone_id']?.toString() != filters.zoneId) {
          return false;
        }

        if (filters.date != null) {
          final rideDate = DateTime.tryParse(row['date']?.toString() ?? '');

          if (rideDate == null || !_isSameDate(rideDate, filters.date!)) {
            return false;
          }
        }

        if (filters.type != null && row['type']?.toString() != filters.type) {
          return false;
        }

        return true;
      }).toList();

      final models = filteredRows.map(RideOfferModel.fromJson).toList();

      _sortRideOffers(models, filters);

      final offers = models.map((model) => model.toEntity()).toList();

      return Right(offers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al obtener ofertas'));
    }
  }

  void _sortRideOffers(List<RideOfferModel> offers, RideOfferFilters filters) {
    final effectiveSort =
        filters.sortBy ?? _firstQuickFilter(filters.quickFilters);

    switch (effectiveSort) {
      case 'price':
        offers.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'driver_rating':
        offers.sort((a, b) => b.driverRating.compareTo(a.driverRating));
        break;
      case 'slots':
        offers.sort((a, b) => b.slots.compareTo(a.slots));
        break;
      case 'departure_time':
      default:
        offers.sort(_compareByDeparture);
        break;
    }
  }

  String? _firstQuickFilter(List<String> quickFilters) {
    const allowedOrder = ['departure_time', 'price', 'slots', 'driver_rating'];

    for (final filter in allowedOrder) {
      if (quickFilters.contains(filter)) {
        return filter;
      }
    }

    return null;
  }

  int _compareByDeparture(RideOfferModel a, RideOfferModel b) {
    final dateComparison = a.date.compareTo(b.date);

    if (dateComparison != 0) {
      return dateComparison;
    }

    return a.departureTime.compareTo(b.departureTime);
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
