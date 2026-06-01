import 'package:shared_preferences/shared_preferences.dart';

import '../../features/user/domain/entities/user_role.dart';

class UserRolePreferences {
  static const String _keyPrefix = 'last_selected_role_user_';

  final SharedPreferences _sharedPreferences;

  UserRolePreferences(this._sharedPreferences);

  UserRole? getLastSelectedRole({required int userId}) {
    final rawValue = _sharedPreferences.getString('$_keyPrefix$userId');
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    for (final role in UserRole.values) {
      if (role.name == rawValue) {
        return role;
      }
    }

    return null;
  }

  Future<void> saveLastSelectedRole({
    required int userId,
    required UserRole role,
  }) {
    return _sharedPreferences.setString('$_keyPrefix$userId', role.name);
  }

  Future<void> clearLastSelectedRole({required int userId}) {
    return _sharedPreferences.remove('$_keyPrefix$userId');
  }
}
