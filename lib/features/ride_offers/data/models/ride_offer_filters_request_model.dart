import '../../domain/entities/ride_offer_filters.dart';

class RideOfferFiltersRequestModel {
  final String? zoneId;
  final String? date;
  final String? tripType;
  final String? sortBy;
  final List<String> quickFilters;

  const RideOfferFiltersRequestModel({
    this.zoneId,
    this.date,
    this.tripType,
    this.sortBy,
    required this.quickFilters,
  });

  factory RideOfferFiltersRequestModel.fromEntity(RideOfferFilters filters) {
    return RideOfferFiltersRequestModel(
      zoneId: filters.zoneId,
      date: filters.date?.toIso8601String(),
      tripType: filters.tripType,
      sortBy: filters.sortBy,
      quickFilters: filters.quickFilters,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (zoneId != null) 'zone_id': zoneId,
      if (date != null) 'date': date,
      if (tripType != null) 'trip_type': tripType,
      if (sortBy != null) 'sort_by': sortBy,
      if (quickFilters.isNotEmpty) 'quick_filters': quickFilters.join(','),
    };
  }

  Map<String, dynamic> toRpcParams() {
    return {
      'p_zone_id': zoneId,
      'p_date': date,
      'p_trip_type': tripType,
      'p_sort_by': sortBy,
      'p_quick_filters': quickFilters,
    };
  }
}
