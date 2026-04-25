import 'package:hive_flutter/hive_flutter.dart';

/// Clase para manejar el almacenamiento local de formularios de viajes
/// cuando no hay conexión a internet
class RideFormOfflineStorage {
  static const String _boxName = 'ride_form_cache';
  static const String _formDataKey = 'pending_ride_form';

  late Box<Map> _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  
  Future<void> savePendingRideForm(Map<String, dynamic> formData) async {
    try {
      await _box.put(_formDataKey, formData);
    } catch (e) {
      throw Exception('Error al guardar formulario: $e');
    }
  }

  
  Map<String, dynamic>? getPendingRideForm() {
    try {
      final data = _box.get(_formDataKey);
      if (data != null) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener formulario: $e');
    }
  }


  bool hasPendingRideForm() {
    return _box.containsKey(_formDataKey);
  }

  
  Future<void> clearPendingRideForm() async {
    try {
      await _box.delete(_formDataKey);
    } catch (e) {
      throw Exception('Error al eliminar formulario: $e');
    }
  }

  
  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Error al limpiar almacenamiento: $e');
    }
  }

  
  Future<void> close() async {
    await _box.close();
  }
}
