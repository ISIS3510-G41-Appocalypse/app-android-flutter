import 'package:hive_flutter/hive_flutter.dart';

class RideFormOfflineStorage {
  static const String _boxName = 'ride_form_cache';
  static const String _pendingFormKey = 'pending_ride_form';
  static const String _draftFormKey = 'ride_form_draft';

  late Box<Map> _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> savePendingRideForm(Map<String, dynamic> formData) async {
    await _saveMap(_pendingFormKey, formData, 'guardar formulario pendiente');
  }

  Map<String, dynamic>? getPendingRideForm() {
    return _getMap(_pendingFormKey, 'obtener formulario pendiente');
  }

  bool hasPendingRideForm() {
    return _box.containsKey(_pendingFormKey);
  }

  Future<void> clearPendingRideForm() async {
    await _deleteKey(_pendingFormKey, 'eliminar formulario pendiente');
  }

  Future<void> saveDraftRideForm(Map<String, dynamic> formData) async {
    await _saveMap(_draftFormKey, formData, 'guardar borrador del formulario');
  }

  Map<String, dynamic>? getDraftRideForm() {
    return _getMap(_draftFormKey, 'obtener borrador del formulario');
  }

  bool hasDraftRideForm() {
    return _box.containsKey(_draftFormKey);
  }

  Future<void> clearDraftRideForm() async {
    await _deleteKey(_draftFormKey, 'eliminar borrador del formulario');
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

  Future<void> _saveMap(
    String key,
    Map<String, dynamic> formData,
    String action,
  ) async {
    try {
      await _box.put(key, formData);
    } catch (e) {
      throw Exception('Error al $action: $e');
    }
  }

  Map<String, dynamic>? _getMap(String key, String action) {
    try {
      final data = _box.get(key);
      if (data != null) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error al $action: $e');
    }
  }

  Future<void> _deleteKey(String key, String action) async {
    try {
      await _box.delete(key);
    } catch (e) {
      throw Exception('Error al $action: $e');
    }
  }
}
