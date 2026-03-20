import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/usecases/get_ride_offers.dart';
import '../../domain/usecases/get_zones.dart';
import '../view/models/ride_offer_view_data.dart';
import 'ride_offers_state.dart';

class RideOffersCubit extends Cubit<RideOffersState> {
  final GetRideOffers getRideOffers;
  final GetZones getZones;

  RideOffersCubit({required this.getRideOffers, required this.getZones})
    : super(RideOffersState.initial());

  Future<void> loadInitialData() async {
    await _loadZones();
    await loadRideOffers();
  }

  Future<void> loadRideOffers() async {
    emit(state.copyWith(status: RideOffersStatus.loading, message: null));

    final result = await getRideOffers(filters: state.filters);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: RideOffersStatus.error,
            message: failure.message,
            offers: const [],
          ),
        );
      },
      (rideOffers) {
        final offers = rideOffers.map(RideOfferViewData.fromEntity).toList();

        if (offers.isEmpty) {
          emit(
            state.copyWith(
              status: RideOffersStatus.empty,
              offers: const [],
              message: 'No encontramos ofertas de viaje para esos filtros',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: RideOffersStatus.success,
            offers: offers,
            message: null,
          ),
        );
      },
    );
  }

  Future<void> _loadZones() async {
    final result = await getZones();

    result.fold((_) {}, (zones) {
      emit(state.copyWith(zones: zones));
    });
  }

  void updateZoneId(String? zoneId) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          zoneId: zoneId,
          clearZoneId: zoneId == null,
        ),
      ),
    );
  }

  void updateDate(DateTime? date) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(date: date, clearDate: date == null),
      ),
    );
  }

  void updateType(String? type) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(type: type, clearType: type == null),
      ),
    );
  }

  void updateSortBy(String? sortBy) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          sortBy: sortBy,
          clearSortBy: sortBy == null,
        ),
      ),
    );
  }

  void toggleQuickFilter(String value) {
    final currentFilters = List<String>.from(state.filters.quickFilters);

    if (currentFilters.contains(value)) {
      currentFilters.remove(value);
    } else {
      currentFilters.add(value);
    }

    emit(
      state.copyWith(
        filters: state.filters.copyWith(quickFilters: currentFilters),
      ),
    );
  }

  Future<void> applyFilters() async {
    await loadRideOffers();
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(filters: const RideOfferFilters()));

    await loadRideOffers();
  }
}
