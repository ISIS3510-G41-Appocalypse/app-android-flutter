import '../../domain/entities/ride.dart';

class RideModel extends Ride {
  const RideModel({
    super.id,
    required super.driverId,
    required super.vehicleId,
    required super.zoneId,
    required super.source,
    required super.destination,
    required super.date,
    required super.departureTime,
    required super.state,
    required super.type,
    required super.price,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        id:json['id'] as int?,
        driverId:json['driver_id'] as int,
        vehicleId:json['vehicle_id'] as int,
        zoneId:json['zone_id'] as int,
        source:json['source'] as String,
        destination:json['destination'] as String,
        date:json['date'] as String,
        departureTime:json['departure_time'] as String,
        state:json['state'] as String,
        type:json['type'] as String,
        price:(json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'driver_id':      driverId,
        'vehicle_id':     vehicleId,
        'zone_id':        zoneId,
        'source':         source,
        'destination':    destination,
        'date':           date,
        'departure_time': departureTime,
        'state':          'OFERTADO',
        'type':           type,
        'price':          price,
      };
}