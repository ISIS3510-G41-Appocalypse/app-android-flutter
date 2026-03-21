import '../../domain/entities/zone.dart';

class ZoneModel {
  final String id;
  final String name;

  const ZoneModel({required this.id, required this.name});

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(id: json['id'].toString(), name: json['name'] as String);
  }

  Zone toEntity() {
    return Zone(id: id, name: name);
  }
}
