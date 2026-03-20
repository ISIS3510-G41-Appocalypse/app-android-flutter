import '../../domain/entities/ride_offer_filters.dart';
import '../view/models/ride_offer_view_data.dart';

enum RideOffersStatus { initial, loading, success, empty, error }

class RideOffersState {
  static const Object _sentinel = Object();

  final RideOffersStatus status;
  final RideOfferFilters filters;
  final List<RideOfferViewData> offers;
  final String? message;

  const RideOffersState({
    required this.status,
    required this.filters,
    required this.offers,
    this.message,
  });

  factory RideOffersState.initial() {
    return const RideOffersState(
      status: RideOffersStatus.initial,
      filters: RideOfferFilters(),
      offers: [],
    );
  }

  RideOffersState copyWith({
    RideOffersStatus? status,
    RideOfferFilters? filters,
    List<RideOfferViewData>? offers,
    Object? message = _sentinel,
  }) {
    return RideOffersState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      offers: offers ?? this.offers,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
    );
  }
}
