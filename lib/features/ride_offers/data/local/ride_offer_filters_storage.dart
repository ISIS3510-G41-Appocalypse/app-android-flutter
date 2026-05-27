import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/ride_offer_filters.dart';

class RideOfferFiltersStorage {
  static const String _boxName = 'filters_storage';
  static const String _filtersKey = 'last_filters';

  late Box<Map> _filtersBox;

  Future<void> initialize() async {
    _filtersBox = await Hive.openBox<Map>(_boxName);
  }

  Future<void> saveFilters(RideOfferFilters filters) async {
    await _filtersBox.put(_filtersKey, {
      'zone_id': filters.zoneId,
      'date': filters.date?.toIso8601String(),
      'time': filters.time,
      'type': filters.type,
      'sort_by': filters.sortBy,
      'quick_filters': filters.quickFilters,
    });
  }

  RideOfferFilters? getFilters() {
    final data = _filtersBox.get(_filtersKey);
    if (data == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);

    return RideOfferFilters(
      zoneId: map['zone_id'] as String?,
      date: map['date'] == null
          ? null
          : DateTime.tryParse(map['date'].toString()),
      time: map['time'] as String?,
      type: map['type'] as String?,
      sortBy: map['sort_by'] as String?,
      quickFilters: List<String>.from(map['quick_filters'] ?? const []),
    );
  }

  Future<void> clearFilters() async {
    await _filtersBox.delete(_filtersKey);
  }
}
