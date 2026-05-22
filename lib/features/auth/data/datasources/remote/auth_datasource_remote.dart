import '../../models/auth_model.dart';

abstract class AuthDataSourceRemote {
  Future<String> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int zoneId,
    required List<String> roles,
    required List<Map<String, dynamic>> paymentMethods,
    required List<Map<String, dynamic>> vehicles,
  });

  Future<AuthModel> login({
    required String email,
    required String password,
  });

  Future<AuthModel> verifySession();

  Future<List<Map<String, dynamic>>> getZonesRows();
}
