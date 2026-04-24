import '../models/user_profile_model.dart';

abstract class UserDataSourceRemote {
  Future<UserProfileModel> getRiderProfile({
    required int riderId,
  });

  Future<UserProfileModel> getDriverProfile({
    required int driverId,
  });
}
