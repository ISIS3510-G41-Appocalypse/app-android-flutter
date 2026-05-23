import 'dart:isolate';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/ride_offer.dart';
import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/ride_offers_repository.dart';
import '../data_sources/ride_offers_remote_datasource.dart';
import '../models/ride_offer_model.dart';
import '../models/zone_model.dart';

class RideOffersRepositoryImpl implements RideOffersRepository {
  final RideOffersRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  RideOffersRepositoryImpl({
    required this.remoteDataSource,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, List<RideOffer>>> getRideOffers({
    required RideOfferFilters filters,
  }) async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Revisa tu conexion e intenta de nuevo.',
        ),
      );
    }

    try {
      final rows = await remoteDataSource.getRideOffersRows();

      final offers = await Isolate.run(() {
        return _processRideOffersInBackground(rows: rows, filters: filters);
      });

      return Right(offers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al obtener ofertas'));
    }
  }

  @override
  Future<Either<Failure, List<Zone>>> getZones() async {
    if (!await networkChecker.hasInternet) {
      return const Left(
        NetworkFailure(
          'No tienes internet. Revisa tu conexion e intenta de nuevo.',
        ),
      );
    }

    try {
      final rows = await remoteDataSource.getZonesRows();

      final zones = rows
          .map(ZoneModel.fromJson)
          .map((model) => model.toEntity())
          .toList();

      return Right(zones);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado al obtener zonas'));
    }
  }
}

List<RideOffer> _processRideOffersInBackground({
  required List<Map<String, dynamic>> rows,
  required RideOfferFilters filters,
}) {
  final now = DateTime.now();

  final filteredRows = rows.where((row) {
    if (row['state']?.toString() != 'OFERTADO') {
      return false;
    }

    final departureDateTime = _parseDepartureDateTimeInBackground(row);
    if (departureDateTime == null || departureDateTime.isBefore(now)) {
      return false;
    }

    if (filters.excludedRideId != null &&
        row['id']?.toString() == filters.excludedRideId) {
      return false;
    }

    if (filters.zoneId != null &&
        row['zone_id']?.toString() != filters.zoneId) {
      return false;
    }

    if (filters.date != null) {
      final rideDate = DateTime.tryParse(row['date']?.toString() ?? '');

      if (rideDate == null ||
          !_isSameDateInBackground(rideDate, filters.date!)) {
        return false;
      }
    }

    if (filters.time != null &&
        row['departure_time']?.toString() != filters.time) {
      return false;
    }

    if (filters.type != null && row['type']?.toString() != filters.type) {
      return false;
    }

    return true;
  }).toList();

  final models = filteredRows.map(RideOfferModel.fromJson).toList();

  _sortRideOffersInBackground(models, filters);

  return models.map((model) => model.toEntity()).toList();
}

void _sortRideOffersInBackground(
  List<RideOfferModel> offers,
  RideOfferFilters filters,
) {
  final effectiveSort =
      filters.sortBy ??
      _firstQuickFilterInBackground(filters.quickFilters) ??
      'driver_rating';

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
      offers.sort(_compareByDepartureInBackground);
      break;
  }
}

String? _firstQuickFilterInBackground(List<String> quickFilters) {
  const allowedOrder = ['departure_time', 'price', 'slots', 'driver_rating'];

  for (final filter in allowedOrder) {
    if (quickFilters.contains(filter)) {
      return filter;
    }
  }

  return null;
}

int _compareByDepartureInBackground(RideOfferModel a, RideOfferModel b) {
  final dateComparison = a.date.compareTo(b.date);

  if (dateComparison != 0) {
    return dateComparison;
  }

  return a.departureTime.compareTo(b.departureTime);
}

bool _isSameDateInBackground(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime? _parseDepartureDateTimeInBackground(Map<String, dynamic> row) {
  final date = row['date']?.toString();
  final time = row['departure_time']?.toString();

  if (date == null || time == null) {
    return null;
  }

  final dateParts = date.split('-');
  final timeParts = time.split(':');

  if (dateParts.length != 3 || timeParts.length < 2) {
    return null;
  }

  final year = int.tryParse(dateParts[0]);
  final month = int.tryParse(dateParts[1]);
  final day = int.tryParse(dateParts[2]);
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  final second = timeParts.length > 2 ? int.tryParse(timeParts[2]) ?? 0 : 0;

  if (year == null ||
      month == null ||
      day == null ||
      hour == null ||
      minute == null) {
    return null;
  }

  return DateTime(year, month, day, hour, minute, second);
}
