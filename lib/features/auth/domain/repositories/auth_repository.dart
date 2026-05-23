import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth.dart';
import '../../../ride_offers/domain/entities/zone.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> saveSignupDraft(Map<String, dynamic> formData);

  Either<Failure, Map<String, dynamic>?> getSignupDraft();

  Future<Either<Failure, void>> clearSignupDraft();

  bool hasSignupDraft();

  Future<Either<Failure, List<Zone>>> getZones();

  Future<Either<Failure, String>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int zoneId,
    required List<String> roles,
    required List<Map<String, dynamic>> paymentMethods,
    required List<Map<String, dynamic>> vehicles,
  });

  Future<Either<Failure, Auth>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, Auth>> verifySession();
}
