import 'package:hive_flutter/hive_flutter.dart';

class RatingsDraftStorage {
  static const String _boxName = 'ratings_drafts';

  late Box<Map> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> saveDraft(String key, Map<String, dynamic> data) async {
    await _box.put(key, data);
  }

  Map<String, dynamic>? getDraft(String key) {
    final data = _box.get(key);
    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  Future<void> clearDraft(String key) async {
    await _box.delete(key);
  }
}
