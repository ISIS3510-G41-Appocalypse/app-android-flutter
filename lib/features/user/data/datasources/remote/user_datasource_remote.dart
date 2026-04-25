import '../../../../auth/domain/entities/auth.dart';
import '../../models/user_model.dart';
import '../../models/profile_model.dart';

abstract class UserDataSourceRemote {
  Future<UserModel> loadUser({
    required Auth auth,
  });

  Future<({ProfileModel? rider, ProfileModel? driver})> loadProfiles({
    required int userId,
  });
}
