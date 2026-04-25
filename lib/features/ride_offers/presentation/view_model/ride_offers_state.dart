import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/entities/zone.dart';
import '../view/models/ride_offer_view_data.dart';

enum RideOffersStatus { initial, loading, success, empty, error }

class RideOffersState {
  static const Object _sentinel = Object();

  final RideOffersStatus status;
  final RideOfferFilters filters;
  final List<RideOfferViewData> offers;
  final List<Zone> zones;
  final String? message;
  final bool isOffline;
  final bool isReserving;
  final String? reservingRideId;
  final bool reservationCreated;

  const RideOffersState({
    required this.status,
    required this.filters,
    required this.offers,
    required this.zones,
    this.message,
    required this.isOffline,
    required this.isReserving,
    this.reservingRideId,
    required this.reservationCreated,
  });

  factory RideOffersState.initial() {
    return const RideOffersState(
      status: RideOffersStatus.initial,
      filters: RideOfferFilters(),
      offers: [],
      zones: [],
      isOffline: false,
      isReserving: false,
      reservingRideId: null,
      reservationCreated: false,
    );
  }

  RideOffersState copyWith({
    RideOffersStatus? status,
    RideOfferFilters? filters,
    List<RideOfferViewData>? offers,
    List<Zone>? zones,
    Object? message = _sentinel,
    bool? isOffline,
    bool? isReserving,
    Object? reservingRideId = _sentinel,
    bool? reservationCreated,
  }) {
    return RideOffersState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      offers: offers ?? this.offers,
      zones: zones ?? this.zones,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
      isOffline: isOffline ?? this.isOffline,
      isReserving: isReserving ?? this.isReserving,
      reservingRideId: identical(reservingRideId, _sentinel)
          ? this.reservingRideId
          : reservingRideId as String?,
      reservationCreated: reservationCreated ?? this.reservationCreated,
    );
  }
}
