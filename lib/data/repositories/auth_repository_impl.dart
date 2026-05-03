import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.client.post('/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      await _apiService.saveToken(token);

      return await getCurrentUser() ?? (throw Exception("Failed to fetch user profile after login"));
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Login failed");
    }
  }

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await _apiService.client.post('/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      // Automatically login after signup
      return await login(email, password);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Signup failed");
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await _apiService.client.get('/users/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (_) {
      // If token is invalid or expired
      await _apiService.deleteToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _apiService.deleteToken();
  }
}
