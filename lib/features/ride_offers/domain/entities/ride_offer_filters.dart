class RideOfferFilters {
  final String? zoneId;
  final DateTime? date;
  final String? tripType;
  final String? sortBy;
  final List<String> quickFilters;

  const RideOfferFilters({
    this.zoneId,
    this.date,
    this.tripType,
    this.sortBy,
    this.quickFilters = const [],
  });

  RideOfferFilters copyWith({
    String? zoneId,
    DateTime? date,
    String? tripType,
    String? sortBy,
    List<String>? quickFilters,
    bool clearZoneId = false,
    bool clearDate = false,
    bool clearTripType = false,
    bool clearSortBy = false,
  }) {
    return RideOfferFilters(
      zoneId: clearZoneId ? null : (zoneId ?? this.zoneId),
      date: clearDate ? null : (date ?? this.date),
      tripType: clearTripType ? null : (tripType ?? this.tripType),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      quickFilters: quickFilters ?? this.quickFilters,
    );
  }
}
