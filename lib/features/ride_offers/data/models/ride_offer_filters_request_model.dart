import '../../domain/entities/ride_offer_filters.dart';

class RideOfferFiltersRequestModel {
  final String? zoneId;
  final String? date;
  final String? type;
  final String? sortBy;
  final List<String> quickFilters;

  const RideOfferFiltersRequestModel({
    this.zoneId,
    this.date,
    this.type,
    this.sortBy,
    required this.quickFilters,
  });

  factory RideOfferFiltersRequestModel.fromEntity(RideOfferFilters filters) {
    return RideOfferFiltersRequestModel(
      zoneId: filters.zoneId,
      date: _formatDate(filters.date),
      type: filters.type,
      sortBy: filters.sortBy,
      quickFilters: filters.quickFilters,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (zoneId != null) 'zone_id': zoneId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (sortBy != null) 'sort_by': sortBy,
      if (quickFilters.isNotEmpty) 'quick_filters': quickFilters.join(','),
    };
  }

  Map<String, dynamic> toRpcParams() {
    return {
      'p_zone_id': zoneId,
      'p_date': date,
      'p_type': type,
      'p_sort_by': sortBy,
      'p_quick_filters': quickFilters,
    };
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }

    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
