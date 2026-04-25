class RideOfferFilters {
  final String? zoneId;
  final DateTime? date;
  final String? time;
  final String? type;
  final String? sortBy;
  final int? excludedDriverId;
  final List<String> quickFilters;

  const RideOfferFilters({
    this.zoneId,
    this.date,
    this.time,
    this.type,
    this.sortBy,
    this.excludedDriverId,
    this.quickFilters = const [],
  });

  RideOfferFilters copyWith({
    String? zoneId,
    DateTime? date,
    String? time,
    String? type,
    String? sortBy,
    int? excludedDriverId,
    List<String>? quickFilters,
    bool clearZoneId = false,
    bool clearDate = false,
    bool clearTime = false,
    bool clearType = false,
    bool clearSortBy = false,
    bool clearExcludedDriverId = false,
  }) {
    return RideOfferFilters(
      zoneId: clearZoneId ? null : (zoneId ?? this.zoneId),
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
      type: clearType ? null : (type ?? this.type),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      excludedDriverId: clearExcludedDriverId
          ? null
          : (excludedDriverId ?? this.excludedDriverId),
      quickFilters: quickFilters ?? this.quickFilters,
    );
  }
}
