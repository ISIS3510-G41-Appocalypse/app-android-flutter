import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/usecases/get_ride_offers.dart';
import '../view/models/ride_offer_view_data.dart';
import 'ride_offers_state.dart';

class RideOffersCubit extends Cubit<RideOffersState> {
  final GetRideOffers getRideOffers;

  RideOffersCubit({required this.getRideOffers})
    : super(RideOffersState.initial());

  Future<void> loadRideOffers() async {
    emit(state.copyWith(status: RideOffersStatus.loading, message: null));

    try {
      final result = await getRideOffers(filters: state.filters);
      final offers = result.map(RideOfferViewData.fromEntity).toList();

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
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: RideOffersStatus.error,
          message: _mapExceptionToMessage(e),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RideOffersStatus.error,
          message: 'Ocurrió un error inesperado',
        ),
      );
    }
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

  void updateTripType(String? tripType) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          tripType: tripType,
          clearTripType: tripType == null,
        ),
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

  String _mapExceptionToMessage(Exception exception) {
    final rawMessage = exception.toString();

    if (rawMessage.startsWith('Exception: ')) {
      return rawMessage.replaceFirst('Exception: ', '');
    }

    return rawMessage;
  }
}
