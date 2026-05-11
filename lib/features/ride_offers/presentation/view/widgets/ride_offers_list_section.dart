import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/offline_state_card.dart';
import '../../view_model/ride_offers_state.dart';
import 'ride_offer_card.dart';

class RideOffersListSection extends StatelessWidget {
  const RideOffersListSection({
    super.key,
    required this.state,
    required this.isReserveEnabled,
    this.reserveDisabledReason,
    required this.currentDriverId,
    required this.reservingRideId,
    required this.onReserve,
    required this.onRetry,
  });

  final RideOffersState state;
  final bool isReserveEnabled;
  final String? reserveDisabledReason;
  final String? currentDriverId;
  final String? reservingRideId;
  final ValueChanged<int> onReserve;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case RideOffersStatus.initial:
      case RideOffersStatus.loading:
        return const _StateCard(
          child: Column(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.amber700,
                ),
              ),
              SizedBox(height: 16),
              Text('Cargando ofertas de viaje...', textAlign: TextAlign.center),
            ],
          ),
        );
      case RideOffersStatus.empty:
        return _StateCard(
          child: Text(
            state.message ?? 'No encontramos ofertas disponibles.',
            textAlign: TextAlign.center,
          ),
        );
      case RideOffersStatus.error:
        if (state.isOffline) {
          return OfflineStateCard(
            title: 'Sin conexion',
            message:
                'No pudimos cargar las ofertas. Algunas funciones requieren internet.',
            onRetry: onRetry,
          );
        }

        return _StateCard(
          child: Text(
            state.message ?? 'Ocurrio un error al cargar las ofertas.',
            textAlign: TextAlign.center,
          ),
        );
      case RideOffersStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.message != null && state.message!.isNotEmpty) ...[
              _InlineError(message: state.message!),
              const SizedBox(height: 16),
            ],
            if (reserveDisabledReason != null &&
                reserveDisabledReason!.isNotEmpty) ...[
              _InlineError(message: reserveDisabledReason!),
              const SizedBox(height: 16),
            ],
            ...List.generate(
              state.offers.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == state.offers.length - 1 ? 0 : 24,
                ),
                child: _buildOfferCard(index),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildOfferCard(int index) {
    final offer = state.offers[index];
    final isOwnRide =
        currentDriverId != null &&
        currentDriverId!.isNotEmpty &&
        offer.driverId == currentDriverId;
    final cardDisabledReason = isOwnRide
        ? 'No puedes reservar tu propio viaje.'
        : reserveDisabledReason;

    return RideOfferCard(
      offer: offer,
      isReserveEnabled: isReserveEnabled && !isOwnRide,
      isReserving: reservingRideId == offer.id,
      reserveDisabledReason: cardDisabledReason,
      onReserve: () => onReserve(index),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: AppTextStyles.primary.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB91C1C),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: DefaultTextStyle(
        style: AppTextStyles.primary.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
        child: child,
      ),
    );
  }
}
