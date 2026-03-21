import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../view_model/ride_offers_state.dart';
import 'ride_offer_card.dart';

class RideOffersListSection extends StatelessWidget {
  const RideOffersListSection({
    super.key,
    required this.state,
    required this.isReserveEnabled,
  });

  final RideOffersState state;
  final bool isReserveEnabled;

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
        return _StateCard(
          child: Text(
            state.message ?? 'Ocurrio un error al cargar las ofertas.',
            textAlign: TextAlign.center,
          ),
        );
      case RideOffersStatus.success:
        return Column(
          children: List.generate(
            state.offers.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == state.offers.length - 1 ? 0 : 24,
              ),
              child: RideOfferCard(
                offer: state.offers[index],
                isReserveEnabled: isReserveEnabled,
              ),
            ),
          ),
        );
    }
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
