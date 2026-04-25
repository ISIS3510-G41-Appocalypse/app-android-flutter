import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/offline_state_card.dart';
import '../../../domain/entities/driver_ride_reservation.dart';
import '../../view_model/driver_rides_cubit.dart';
import '../../view_model/driver_rides_state.dart';
import '../models/driver_ride_view_data.dart';
import 'driver_ride_card.dart';

class DriverRidesContentSection extends StatelessWidget {
  const DriverRidesContentSection({super.key, required this.state});

  final DriverRidesState state;

  String _friendlyMessage(String? message) {
    final raw = message?.trim();
    if (raw == null || raw.isEmpty) {
      return 'Ocurrio un error al cargar tu viaje.';
    }

    final normalized = raw.toLowerCase();
    if (normalized.contains('connection reset by peer') ||
        normalized.contains('socketexception') ||
        normalized.contains('connection errored') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('network is unreachable') ||
        normalized.contains('no tienes internet')) {
      return 'No tienes internet en este momento. Cuando vuelva la conexion podras publicar o consultar tu viaje.';
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case DriverRidesStatus.initial:
      case DriverRidesStatus.loading:
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
              Text(
                'Cargando tu viaje como conductor...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case DriverRidesStatus.empty:
        return _StateCard(
          child: Column(
            children: [
              Text(
                state.message ?? 'Aun no tienes un viaje publicado',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.createRide);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Publicar viaje',
                    style: AppTextStyles.primary.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case DriverRidesStatus.error:
        if (state.isOffline) {
          return OfflineStateCard(
            title: 'Sin conexion',
            message:
                'No pudimos cargar tus viajes. Revisa tu conexion e intenta de nuevo.',
            onRetry: () {
              context.read<DriverRidesCubit>().reloadActiveRide();
            },
          );
        }

        return _StateCard(
          child: Column(
            children: [
              Text(
                _friendlyMessage(state.message),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<DriverRidesCubit>().reloadActiveRide();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue900,
                    side: const BorderSide(color: AppColors.blue900),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Reintentar',
                    style: AppTextStyles.primary.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case DriverRidesStatus.success:
        final rideViewData = DriverRideViewData.fromEntity(state.ride!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DriverRideCard(
              ride: rideViewData,
              onStart: () => context.read<DriverRidesCubit>().startRide(),
              onCancel: () => context.read<DriverRidesCubit>().cancelRide(),
              onFinish: () => context.read<DriverRidesCubit>().finishRide(),
              isUpdating: state.isUpdating,
              updatingAction: state.updatingAction,
              message: state.message,
            ),
            const SizedBox(height: 24),
            _PassengersSectionCard(
              title: 'Solicitudes de reserva',
              description: 'Pasajeros que solicitaron un cupo',
              emptyLabel:
                  'Todavia no hay solicitudes de reserva para este viaje.',
              reservations: state.ride!.pendingReservations,
              showActions: true,
              updatingReservationId: state.updatingReservationId,
              updatingAction: state.updatingAction,
              isUpdating: state.isUpdating,
            ),
            const SizedBox(height: 16),
            _PassengersSectionCard(
              title: 'Pasajeros confirmados',
              description: 'Pasajeros con cupo confirmado',
              emptyLabel:
                  'Todavia no hay pasajeros confirmados para este viaje.',
              reservations: state.ride!.acceptedReservations,
              showActions: false,
              updatingReservationId: state.updatingReservationId,
              updatingAction: state.updatingAction,
              isUpdating: state.isUpdating,
            ),
          ],
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

class _PassengersSectionCard extends StatelessWidget {
  const _PassengersSectionCard({
    required this.title,
    required this.description,
    required this.emptyLabel,
    required this.reservations,
    required this.showActions,
    required this.updatingReservationId,
    required this.updatingAction,
    required this.isUpdating,
  });

  final String title;
  final String description;
  final String emptyLabel;
  final List<DriverRideReservation> reservations;
  final bool showActions;
  final String? updatingReservationId;
  final String? updatingAction;
  final bool isUpdating;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.primary.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.primary.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          if (reservations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                emptyLabel,
                style: AppTextStyles.primary.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            )
          else
            Column(
              children: List.generate(reservations.length, (index) {
                final reservation = reservations[index];
                final isThisUpdating =
                    isUpdating &&
                    updatingReservationId == reservation.reservationId;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == reservations.length - 1 ? 0 : 12,
                  ),
                  child: _PassengerReservationCard(
                    reservation: reservation,
                    showActions: showActions,
                    isUpdating: isThisUpdating,
                    updatingAction: updatingAction,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _PassengerReservationCard extends StatelessWidget {
  const _PassengerReservationCard({
    required this.reservation,
    required this.showActions,
    required this.isUpdating,
    required this.updatingAction,
  });

  final DriverRideReservation reservation;
  final bool showActions;
  final bool isUpdating;
  final String? updatingAction;

  @override
  Widget build(BuildContext context) {
    final cancellationText =
        '${(reservation.cancellationOdds * 100).toStringAsFixed(0)}% cancelacion';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reservation.riderName,
            style: AppTextStyles.primary.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _PassengerMetric(
                icon: Icons.star_rounded,
                label: reservation.rating.toStringAsFixed(1),
                color: AppColors.amber700,
              ),
              _PassengerMetric(
                icon: Icons.event_busy_rounded,
                label: cancellationText,
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            context.read<DriverRidesCubit>().rejectReservation(
                              reservation.reservationId,
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isUpdating && updatingAction == 'reject_reservation'
                          ? 'Cancelando...'
                          : 'Cancelar',
                      style: AppTextStyles.primary.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            context.read<DriverRidesCubit>().acceptReservation(
                              reservation.reservationId,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal600,
                      disabledBackgroundColor: AppColors.teal600.withValues(
                        alpha: 0.6,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isUpdating && updatingAction == 'accept_reservation'
                          ? 'Aceptando...'
                          : 'Aceptar',
                      style: AppTextStyles.primary.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PassengerMetric extends StatelessWidget {
  const _PassengerMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.primary.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
