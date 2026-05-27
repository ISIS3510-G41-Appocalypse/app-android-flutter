import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/performance/performance_features.dart';
import '../../../../core/performance/performance_time_tracker.dart';
import '../../../payments/domain/usecases/has_blocking_payments.dart';
import '../../../ride_recommendation/domain/entities/ride_recommendation.dart';
import '../../../ride_recommendation/domain/usecases/get_ride_recommendation.dart';
import '../../../rider_rides/domain/usecases/create_reservation.dart';
import '../../data/local/ride_offer_filters_storage.dart';
import '../../domain/entities/ride_offer_filters.dart';
import '../../domain/usecases/get_ride_offers.dart';
import '../../domain/usecases/get_zones.dart';
import '../view/models/ride_offer_view_data.dart';
import 'ride_offers_state.dart';

class RideOffersCubit extends Cubit<RideOffersState> {
  final GetRideOffers getRideOffers;
  final GetZones getZones;
  final CreateReservation createReservation;
  final GetRideRecommendation getRideRecommendation;
  final HasBlockingPayments hasBlockingPayments;
  final PerformanceTimeTracker performanceTimeTracker;
  final RideOfferFiltersStorage filtersStorage;
  String? _preferredZoneId;
  String? _excludedRideId;

  RideOffersCubit({
    required this.getRideOffers,
    required this.getZones,
    required this.createReservation,
    required this.getRideRecommendation,
    required this.hasBlockingPayments,
    required this.performanceTimeTracker,
    required this.filtersStorage,
  }) : super(RideOffersState.initial(initialDate: _today()));

  Future<RideRecommendation?> loadRideRecommendation({
    required int? riderId,
    required int driverId,
  }) async {
    if (riderId == null) {
      return null;
    }

    final result = await getRideRecommendation(
      riderId: riderId,
      driverId: driverId,
    );

    RideRecommendation? recommendation;
    result.fold((_) {}, (value) {
      recommendation = value;
    });

    return recommendation;
  }

  Future<Failure?> validateRecommendationAvailability({
    required int? riderId,
    required int driverId,
  }) async {
    if (riderId == null) {
      return null;
    }

    final result = await getRideRecommendation(
      riderId: riderId,
      driverId: driverId,
    );

    Failure? failure;
    result.fold((value) {
      failure = value;
    }, (_) {});

    return failure;
  }

  Future<void> loadInitialData({
    String? preferredZoneId,
    String? excludedRideId,
  }) async {
    _preferredZoneId = preferredZoneId;
    _excludedRideId = excludedRideId;
    final storedFilters = filtersStorage.getFilters();

    if (storedFilters != null) {
      emit(
        state.copyWith(
          filters: storedFilters.copyWith(
            zoneId: preferredZoneId ?? storedFilters.zoneId,
            excludedRideId: excludedRideId,
          ),
        ),
      );
    } else if (preferredZoneId != null || excludedRideId != null) {
      emit(
        state.copyWith(
          filters: state.filters.copyWith(
            zoneId: preferredZoneId,
            excludedRideId: excludedRideId,
          ),
        ),
      );
    }

    await _loadZones();
    await loadRideOffers();
  }

  Future<void> syncDefaultFilters({String? preferredZoneId}) async {
    _preferredZoneId = preferredZoneId;

    final shouldUpdateZone =
        preferredZoneId != null && state.filters.zoneId == null;
    final shouldUpdateDate = state.filters.date == null;

    if (!shouldUpdateZone && !shouldUpdateDate) {
      return;
    }

    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          zoneId: shouldUpdateZone ? preferredZoneId : state.filters.zoneId,
          date: shouldUpdateDate ? _today() : state.filters.date,
        ),
      ),
    );

    await loadRideOffers();
  }

  Future<void> loadRideOffers() async {
    emit(
      state.copyWith(
        status: RideOffersStatus.loading,
        message: null,
        isOffline: false,
        reservationCreated: false,
      ),
    );

    final result = await getRideOffers(filters: state.filters);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: RideOffersStatus.error,
            message: failure.message,
            offers: const [],
            isOffline: failure is NetworkFailure,
            reservationCreated: false,
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
              isOffline: false,
              reservationCreated: false,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: RideOffersStatus.success,
            offers: offers,
            message: null,
            isOffline: false,
            reservationCreated: false,
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

  void updateTime(String? time) {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(time: time, clearTime: time == null),
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
    await filtersStorage.saveFilters(state.filters);
    await loadRideOffers();
  }

  Future<void> clearFilters() async {
    final defaultFilters = RideOfferFilters(
      zoneId: _preferredZoneId,
      date: _today(),
      excludedRideId: _excludedRideId,
    );

    emit(state.copyWith(filters: defaultFilters));

    await filtersStorage.saveFilters(defaultFilters);
    await loadRideOffers();
  }

  Future<void> updateExcludedRideId(String? rideId) async {
    if (_excludedRideId == rideId) {
      return;
    }

    _excludedRideId = rideId;
    emit(
      state.copyWith(
        filters: state.filters.copyWith(
          excludedRideId: rideId,
          clearExcludedRideId: rideId == null,
        ),
      ),
    );

    await loadRideOffers();
  }

  Future<void> reserveRide({
    required RideOfferViewData offer,
    required int? riderId,
    required String? currentDriverId,
    required bool hasActiveDriverRide,
    Stopwatch? createReservationFrontEndStopwatch,
  }) async {
    if (state.isReserving) {
      return;
    }

    if (hasActiveDriverRide) {
      emit(
        state.copyWith(
          message:
              'Debes cancelar o finalizar tu viaje activo como conductor antes de reservar otro viaje.',
          isOffline: false,
          reservationCreated: false,
        ),
      );
      return;
    }

    if (currentDriverId != null &&
        currentDriverId.isNotEmpty &&
        offer.driverId.toString() == currentDriverId) {
      emit(
        state.copyWith(
          message: 'No puedes reservar tu propio viaje.',
          isOffline: false,
          reservationCreated: false,
        ),
      );
      return;
    }

    final blockingPaymentsResult = await hasBlockingPayments(riderId: riderId);
    bool hasOpenPayments = false;
    Failure? paymentValidationFailure;
    blockingPaymentsResult.fold(
      (failure) {
        paymentValidationFailure = failure;
      },
      (value) {
        hasOpenPayments = value;
      },
    );

    if (paymentValidationFailure != null) {
      emit(
        state.copyWith(
          message: paymentValidationFailure!.message,
          isOffline: paymentValidationFailure is NetworkFailure,
          reservationCreated: false,
        ),
      );
      return;
    }

    if (hasOpenPayments) {
      emit(
        state.copyWith(
          message:
              'No puedes reservar un nuevo viaje porque tienes pagos pendientes.',
          isOffline: false,
          reservationCreated: false,
        ),
      );
      return;
    }

    final stopwatch =
        createReservationFrontEndStopwatch ?? (Stopwatch()..start());

    emit(
      state.copyWith(
        isReserving: true,
        reservingRideId: offer.id,
        message: null,
        isOffline: false,
        reservationCreated: false,
      ),
    );

    final result = await createReservation(
      rideId: offer.id,
      riderId: riderId,
      meetingPoint: offer.source,
      destinationPoint: offer.destination,
    );

    result.fold(
      (failure) {
        stopwatch.stop();

        if (failure is! NetworkFailure) {
          unawaited(
            performanceTimeTracker.track(
              feature: PerformanceFeatures.createReservation,
              duration: stopwatch.elapsedMilliseconds.toDouble(),
              source: PerformanceSources.frontEnd,
            ),
          );
        }

        emit(
          state.copyWith(
            isReserving: false,
            reservingRideId: null,
            message: failure.message,
            isOffline: failure is NetworkFailure,
            reservationCreated: false,
          ),
        );
      },
      (_) {
        stopwatch.stop();

        unawaited(
          performanceTimeTracker.track(
            feature: PerformanceFeatures.createReservation,
            duration: stopwatch.elapsedMilliseconds.toDouble(),
            source: PerformanceSources.frontEnd,
          ),
        );

        emit(
          state.copyWith(
            isReserving: false,
            reservingRideId: null,
            message: null,
            isOffline: false,
            reservationCreated: true,
          ),
        );
      },
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
