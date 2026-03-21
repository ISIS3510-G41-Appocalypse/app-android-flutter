import '../../domain/entities/zone.dart';

class ZoneModel extends Zone {
  const ZoneModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) => ZoneModel(
        id:json['id'] as int,
        name:json['name'] as String,
        description:json['description'] as String,
      );
}