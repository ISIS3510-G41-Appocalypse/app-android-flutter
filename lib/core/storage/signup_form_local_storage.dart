import 'package:hive_flutter/hive_flutter.dart';

class SignupFormLocalStorage {
  static const String _boxName = 'signup_form_cache';
  static const String _draftKey = 'signup_form_draft';

  late Box<Map> _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> saveDraft(Map<String, dynamic> formData) async {
    try {
      await _box.put(_draftKey, formData);
    } catch (e) {
      throw Exception('Error al guardar borrador de registro: $e');
    }
  }

  Map<String, dynamic>? getDraft() {
    try {
      final data = _box.get(_draftKey);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception('Error al obtener borrador de registro: $e');
    }
  }

  bool hasDraft() {
    return _box.containsKey(_draftKey);
  }

  Future<void> clearDraft() async {
    try {
      await _box.delete(_draftKey);
    } catch (e) {
      throw Exception('Error al eliminar borrador de registro: $e');
    }
  }
}
