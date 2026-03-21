import 'package:flutter/material.dart';
import '../../domain/entities/reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reserva #${reservation.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Chip(
                  label: Text(reservation.state),
                  backgroundColor: Colors.amber.shade100,
                  labelStyle: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Destino: ${reservation.destinationPoint}'),
            Text('Punto de encuentro: ${reservation.meetingPoint}'),
            Text('A tiempo pasajero: ${reservation.onTimeRider ? "Sí" : "No"}'),
            Text('A tiempo conductor: ${reservation.onTimeDriver ? "Sí" : "No"}'),
            Text('ID del viaje: ${reservation.rideId}'),
          ],
        ),
      ),
    );
  }
}
