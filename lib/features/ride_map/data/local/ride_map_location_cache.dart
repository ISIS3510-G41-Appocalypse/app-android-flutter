import 'package:hive_flutter/hive_flutter.dart';

import '../models/ride_map_location_model.dart';

class RideMapLocationCache {
  static const String _boxName = 'ride_map_location_cache';

  late Box<List> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<List>(_boxName);
  }

  Future<void> saveLocations({
    required String rideId,
    required List<RideMapLocationModel> locations,
  }) async {
    await _box.put(
      rideId,
      locations.map((location) => location.toJson()).toList(),
    );
  }

  List<RideMapLocationModel> getLocations({required String rideId}) {
    final cached = _box.get(rideId);
    if (cached == null) {
      return const [];
    }

    return cached
        .whereType<Map>()
        .map(
          (item) =>
              RideMapLocationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
