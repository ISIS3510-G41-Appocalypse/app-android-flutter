import 'package:hive_flutter/hive_flutter.dart';

import '../../models/user_model.dart';
import 'user_datasource_local.dart';

class UserDataSourceLocalStorage implements UserDataSourceLocal {
  static const String _boxName = 'user_cache';
  static const String _userPrefix = 'user';

  late Box<Map> _box;

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  @override
  Future<void> saveUser({required UserModel user}) async {
    await _box.put(_key(user.authId), {
      'updated_at': DateTime.now().toIso8601String(),
      'user': user.toCacheJson(),
    });
  }

  @override
  UserModel? getUser({required String authId}) {
    final data = _box.get(_key(authId));
    if (data == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(data);
    final rawUser = map['user'];
    if (rawUser is! Map) {
      return null;
    }

    return UserModel.fromCacheJson(Map<String, dynamic>.from(rawUser));
  }

  @override
  Future<void> clearUser({required String authId}) async {
    await _box.delete(_key(authId));
  }

  String _key(String authId) => '$_userPrefix:$authId';
}
