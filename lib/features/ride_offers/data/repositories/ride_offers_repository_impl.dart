import '../../domain/entities/ride_offer.dart';
import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/repositories/ride_offers_repository.dart';
import '../data_sources/ride_offers_remote_datasource.dart';
import '../models/ride_offer_model.dart';

class RideOffersRepositoryImpl implements RideOffersRepository {
  final RideOffersRemoteDataSource remoteDataSource;

  RideOffersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RideOffer>> getRideOffers({
    required RideOfferFilters filters,
  }) async {
    final results = await Future.wait([
      remoteDataSource.getRides(),
      remoteDataSource.getVehicles(),
      remoteDataSource.getDrivers(),
      remoteDataSource.getUsers(),
      remoteDataSource.getZones(),
    ]);

    final rides = results[0];
    final vehicles = results[1];
    final drivers = results[2];
    final users = results[3];
    final zones = results[4];

    final vehiclesById = _indexById(vehicles);
    final driversById = _indexById(drivers);
    final usersById = _indexById(users);
    final zonesById = _indexById(zones);
    final rideCountsByDriverId = _countRidesByDriver(rides);

    final filteredRides = rides.where((ride) {
      if (ride['state']?.toString() != 'OFERTADO') {
        return false;
      }

      if (filters.zoneId != null &&
          ride['zone_id']?.toString() != filters.zoneId) {
        return false;
      }

      if (filters.date != null) {
        final rideDate = DateTime.tryParse(ride['date']?.toString() ?? '');

        if (rideDate == null || !_isSameDate(rideDate, filters.date!)) {
          return false;
        }
      }

      if (filters.type != null && ride['type']?.toString() != filters.type) {
        return false;
      }

      return true;
    }).toList();

    final models = filteredRides
        .map(
          (ride) => _buildRideOfferModel(
            ride: ride,
            vehiclesById: vehiclesById,
            driversById: driversById,
            usersById: usersById,
            zonesById: zonesById,
            rideCountsByDriverId: rideCountsByDriverId,
          ),
        )
        .toList();

    _sortRideOffers(models, filters);

    return models.map((model) => model.toEntity()).toList();
  }

  Map<String, Map<String, dynamic>> _indexById(
    List<Map<String, dynamic>> items,
  ) {
    final map = <String, Map<String, dynamic>>{};

    for (final item in items) {
      final id = item['id']?.toString();

      if (id != null) {
        map[id] = item;
      }
    }

    return map;
  }

  Map<String, int> _countRidesByDriver(List<Map<String, dynamic>> rides) {
    final counts = <String, int>{};

    for (final ride in rides) {
      final driverId = ride['driver_id']?.toString();

      if (driverId == null) {
        continue;
      }

      counts[driverId] = (counts[driverId] ?? 0) + 1;
    }

    return counts;
  }

  RideOfferModel _buildRideOfferModel({
    required Map<String, dynamic> ride,
    required Map<String, Map<String, dynamic>> vehiclesById,
    required Map<String, Map<String, dynamic>> driversById,
    required Map<String, Map<String, dynamic>> usersById,
    required Map<String, Map<String, dynamic>> zonesById,
    required Map<String, int> rideCountsByDriverId,
  }) {
    final driverId = ride['driver_id']?.toString();
    final vehicleId = ride['vehicle_id']?.toString();
    final zoneId = ride['zone_id']?.toString();

    final driver = driversById[driverId];
    final user = usersById[driver?['user_id']?.toString()];
    final vehicle = vehiclesById[vehicleId];
    final zone = zonesById[zoneId];

    final firstName = user?['first_name']?.toString() ?? '';
    final lastName = user?['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();

    return RideOfferModel.fromJson({
      'id': ride['id'],
      'driver_name': fullName.isEmpty ? 'Conductor' : fullName,
      'driver_rating': driver?['rating'] ?? 0,
      'trips_count': rideCountsByDriverId[driverId] ?? 0,
      'price': ride['price'] ?? 0,
      'source': ride['source'] ?? '',
      'destination': ride['destination'] ?? '',
      'date': ride['date'],
      'departure_time': ride['departure_time'] ?? '00:00:00',
      'slots': vehicle?['number_slots'] ?? 0,
      'car_model': vehicle?['model'] ?? '',
      'zone_name': zone?['name'] ?? '',
      'type': ride['type'] ?? '',
    });
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
