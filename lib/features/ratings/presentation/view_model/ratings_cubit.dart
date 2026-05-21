import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/rate_driver.dart';
import '../../domain/entities/rate_rider.dart';
import '../../domain/usecases/submit_driver_rating.dart';
import '../../domain/usecases/submit_rider_ratings.dart';
import 'ratings_state.dart';

class RatingsCubit extends Cubit<RatingsState> {
  final SubmitDriverRating submitDriverRatingUseCase;
  final SubmitRiderRatings submitRiderRatingsUseCase;

  RatingsCubit({
    required this.submitDriverRatingUseCase,
    required this.submitRiderRatingsUseCase,
  }) : super(RatingsState.initial());

  Future<void> submitDriverRating(RateDriver rating) async {
    if (state.status == RatingsStatus.submitting) {
      return;
    }

    emit(const RatingsState(status: RatingsStatus.submitting));

    final result = await submitDriverRatingUseCase(rating);
    result.fold(
      (failure) => emit(
        RatingsState(status: RatingsStatus.error, message: failure.message),
      ),
      (_) => emit(
        const RatingsState(
          status: RatingsStatus.success,
          message: 'Calificacion enviada.',
        ),
      ),
    );
  }

  Future<void> submitRiderRatings(List<RateRider> ratings) async {
    if (state.status == RatingsStatus.submitting) {
      return;
    }

    emit(const RatingsState(status: RatingsStatus.submitting));

    final result = await submitRiderRatingsUseCase(ratings);
    result.fold(
      (failure) => emit(
        RatingsState(status: RatingsStatus.error, message: failure.message),
      ),
      (_) => emit(
        const RatingsState(
          status: RatingsStatus.success,
          message: 'Calificaciones enviadas.',
        ),
      ),
    );
  }
}
