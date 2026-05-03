import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}
