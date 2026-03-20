import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/data_sources/ride_offers_remote_datasource.dart';
import '../data/data_sources/ride_offers_remote_datasource_impl.dart';
import '../data/repositories/ride_offers_repository_impl.dart';
import '../domain/repositories/ride_offers_repository.dart';
import '../domain/usecases/get_ride_offers.dart';
import '../presentation/view_model/ride_offers_cubit.dart';

class RideOffersInjection {
  const RideOffersInjection._();

  static TokenStorage createTokenStorage() {
    return TokenStorage();
  }

  static DioClient createDioClient({required TokenStorage tokenStorage}) {
    return DioClient(tokenStorage: tokenStorage);
  }

  static RideOffersRemoteDataSource createRemoteDataSource({
    required DioClient dioClient,
  }) {
    return RideOffersRemoteDataSourceImpl(dio: dioClient.dio);
  }

  static RideOffersRepository createRepository({
    required RideOffersRemoteDataSource remoteDataSource,
  }) {
    return RideOffersRepositoryImpl(remoteDataSource: remoteDataSource);
  }

  static GetRideOffers createGetRideOffers({
    required RideOffersRepository repository,
  }) {
    return GetRideOffers(repository);
  }

  static RideOffersCubit createCubit() {
    final tokenStorage = createTokenStorage();
    final dioClient = createDioClient(tokenStorage: tokenStorage);
    final remoteDataSource = createRemoteDataSource(dioClient: dioClient);
    final repository = createRepository(remoteDataSource: remoteDataSource);
    final getRideOffers = createGetRideOffers(repository: repository);

    return RideOffersCubit(getRideOffers: getRideOffers);
  }
}
