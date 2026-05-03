import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

String get _baseUrl {
  if (kIsWeb) return 'http://127.0.0.1:8000';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiService(this._dio, this._storage) {
    _dio.options.baseUrl = _baseUrl;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach token to every request if it exists
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Dio get client => _dio;
}

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final apiServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiService(Dio(), storage);
});
