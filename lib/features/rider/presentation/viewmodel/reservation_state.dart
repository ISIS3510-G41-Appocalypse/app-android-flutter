part of 'reservation_cubit.dart';

abstract class ReservationState {}

class ReservationInitial extends ReservationState {}
class ReservationLoading extends ReservationState {}
class ReservationLoaded extends ReservationState {
  final Reservation reservation;
  ReservationLoaded(this.reservation);
}
class ReservationEmpty extends ReservationState {}
class ReservationError extends ReservationState {
  final String message;
  ReservationError(this.message);
}
