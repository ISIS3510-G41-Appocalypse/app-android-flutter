import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../ride_offers/domain/entities/zone.dart';
import '../../../ride_offers/data/models/zone_model.dart';
import '../models/auth_model.dart';
import '../datasources/local/auth_datasource_local.dart';
import '../datasources/remote/auth_datasource_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSourceRemote dataSourceRemote;
  final AuthDataSourceLocal dataSourceLocal;
  final NetworkChecker networkChecker;

  AuthRepositoryImpl({
    required this.dataSourceRemote,
    required this.dataSourceLocal,
    required this.networkChecker,
  });

  @override
  Future<Either<Failure, List<Zone>>> getZones() async {
    try {
      if (!await networkChecker.hasInternet) {
        return const Left(
          NetworkFailure('No tienes internet. Intenta de nuevo mas tarde.'),
        );
      }

      final rows = await dataSourceRemote.getZonesRows();
      final zones = rows
          .map(ZoneModel.fromJson)
          .map((model) => model.toEntity())
          .toList();

      return Right(zones);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No fue posible cargar las zonas'));
    }
  }

  @override
  Future<Either<Failure, String>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int zoneId,
    required List<String> roles,
    required List<Map<String, dynamic>> paymentMethods,
    required List<Map<String, dynamic>> vehicles,
  }) async {
    try {
      if (!await networkChecker.hasInternet) {
        return const Left(
          NetworkFailure('No tienes internet. Intenta de nuevo mas tarde.'),
        );
      }

      final authId = await dataSourceRemote.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        zoneId: zoneId,
        roles: roles,
        paymentMethods: paymentMethods,
        vehicles: vehicles,
      );

      return Right(authId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('No pudimos crear tu cuenta. Intenta de nuevo.'));
    }
  }

  @override
  Future<Either<Failure, Auth>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (!await networkChecker.hasInternet) {
        return const Left(
          NetworkFailure('No tienes internet. Intenta de nuevo mas tarde.'),
        );
      }

      final auth = await dataSourceRemote.login(
        email: email,
        password: password,
      );

      await dataSourceLocal.saveSession(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      return Right(auth);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error inesperado en login'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSourceLocal.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al cerrar sesion'));
    }
  }

  @override
  Future<Either<Failure, Auth>> verifySession() async {
    try {
      final hasSession = await dataSourceLocal.hasSession();
      if (!hasSession) {
        return const Left(ServerFailure('No hay token guardado'));
      }

      AuthModel auth;
      try {
        auth = await dataSourceRemote.verifySession();
      } on ServerException catch (e) {
        if (e.message != 'La sesion expiro') {
          rethrow;
        }
        await dataSourceLocal.clearSession();
        return const Left(ServerFailure('La sesion expiro'));
      }

      return Right(auth);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Error al restaurar sesion'));
    }
  }
}
