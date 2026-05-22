import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../data/local/ratings_draft_storage.dart';
import '../../domain/entities/rate_driver.dart';
import '../../domain/entities/rate_rider.dart';
import '../../domain/usecases/submit_driver_rating.dart';
import '../../domain/usecases/submit_rider_ratings.dart';
import 'ratings_state.dart';

class RatingsCubit extends Cubit<RatingsState> {
  final SubmitDriverRating submitDriverRatingUseCase;
  final SubmitRiderRatings submitRiderRatingsUseCase;
  final RatingsDraftStorage draftStorage;
  final NetworkChecker networkChecker;

  RatingsCubit({
    required this.submitDriverRatingUseCase,
    required this.submitRiderRatingsUseCase,
    required this.draftStorage,
    required this.networkChecker,
  }) : super(RatingsState.initial());

  Future<void> loadDraft(String draftKey) async {
    final draft = draftStorage.getDraft(draftKey);
    emit(
      state.copyWith(
        hasDraft: draft != null,
        draftData: draft,
        message: draft != null ? 'Restauramos tu borrador guardado.' : null,
      ),
    );
  }

  Future<void> saveDraft(String draftKey, Map<String, dynamic> data) async {
    await draftStorage.saveDraft(draftKey, data);
    emit(state.copyWith(hasDraft: true));
  }

  Future<void> clearDraft(String draftKey) async {
    await draftStorage.clearDraft(draftKey);
    emit(
      state.copyWith(
        hasDraft: false,
        draftData: null,
        isOffline: false,
        message: null,
      ),
    );
  }

  Future<void> submitDriverRating({
    required String draftKey,
    required RateDriver rating,
  }) async {
    if (state.status == RatingsStatus.submitting) {
      return;
    }

    if (!await networkChecker.hasInternet) {
      emit(
        state.copyWith(
          status: RatingsStatus.error,
          isOffline: true,
          hasDraft: true,
          message:
              'No tienes internet. Guardamos tu calificacion para reintentar.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RatingsStatus.submitting,
        isOffline: false,
        message: null,
      ),
    );

    final result = await submitDriverRatingUseCase(rating);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: RatingsStatus.error,
            isOffline: failure is NetworkFailure,
            message: failure.message,
          ),
        );
      },
      (_) async {
        await draftStorage.clearDraft(draftKey);
        emit(
          state.copyWith(
            status: RatingsStatus.success,
            message: 'Calificacion enviada.',
            isOffline: false,
            hasDraft: false,
            draftData: null,
          ),
        );
      },
    );
  }

  Future<void> submitRiderRatings({
    required String draftKey,
    required List<RateRider> ratings,
  }) async {
    if (state.status == RatingsStatus.submitting) {
      return;
    }

    if (!await networkChecker.hasInternet) {
      emit(
        state.copyWith(
          status: RatingsStatus.error,
          isOffline: true,
          hasDraft: true,
          message:
              'No tienes internet. Guardamos tus calificaciones para reintentar.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RatingsStatus.submitting,
        isOffline: false,
        message: null,
      ),
    );

    final result = await submitRiderRatingsUseCase(ratings);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: RatingsStatus.error,
            isOffline: failure is NetworkFailure,
            message: failure.message,
          ),
        );
      },
      (_) async {
        await draftStorage.clearDraft(draftKey);
        emit(
          state.copyWith(
            status: RatingsStatus.success,
            message: 'Calificaciones enviadas.',
            isOffline: false,
            hasDraft: false,
            draftData: null,
          ),
        );
      },
    );
  }
}
