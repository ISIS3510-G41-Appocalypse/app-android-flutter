class RideOfferFilters {
  final String? zoneId;
  final DateTime? date;
  final String? time;
  final String? type;
  final String? sortBy;
  final String? excludedRideId;
  final List<String> quickFilters;

  const RideOfferFilters({
    this.zoneId,
    this.date,
    this.time,
    this.type,
    this.sortBy,
    this.excludedRideId,
    this.quickFilters = const [],
  });

  RideOfferFilters copyWith({
    String? zoneId,
    DateTime? date,
    String? time,
    String? type,
    String? sortBy,
    String? excludedRideId,
    List<String>? quickFilters,
    bool clearZoneId = false,
    bool clearDate = false,
    bool clearTime = false,
    bool clearType = false,
    bool clearSortBy = false,
    bool clearExcludedRideId = false,
  }) {
    return RideOfferFilters(
      zoneId: clearZoneId ? null : (zoneId ?? this.zoneId),
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
      type: clearType ? null : (type ?? this.type),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      excludedRideId: clearExcludedRideId
          ? null
          : (excludedRideId ?? this.excludedRideId),
      quickFilters: quickFilters ?? this.quickFilters,
    );
  }
}
