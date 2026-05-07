import 'dart:developer' as dev;

import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://reqres.in/api';
  static const _apiKey = 'free_user_3DNh6gStCD7MAS70WTD52IeCBax';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'x-api-key': _apiKey,
          },
        ),
      );

      dev.log('[AUTH] login response ${response.statusCode}: ${response.data}',
          name: 'AuthRemoteDatasource');
      final token = response.data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('Сервер не подтвердил вход');
      }
      return token;
    } on DioException catch (e) {
      dev.log(
        '[AUTH] login error ${e.response?.statusCode}: ${e.response?.data}',
        name: 'AuthRemoteDatasource',
        error: e,
      );
      throw Exception(
        _mapAuthError(
          e,
          fallback: 'Нет подключения к серверу авторизации',
          action: 'вход',
        ),
      );
    }
  }

  Future<String> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'x-api-key': _apiKey,
          },
        ),
      );

      dev.log(
          '[AUTH] register response ${response.statusCode}: ${response.data}',
          name: 'AuthRemoteDatasource');
      final token = response.data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('Сервер не подтвердил регистрацию');
      }
      return token;
    } on DioException catch (e) {
      dev.log(
        '[AUTH] register error ${e.response?.statusCode}: ${e.response?.data}',
        name: 'AuthRemoteDatasource',
        error: e,
      );
      throw Exception(
        _mapAuthError(
          e,
          fallback: 'Нет подключения к серверу авторизации',
          action: 'регистрация',
        ),
      );
    }
  }

  String _mapAuthError(
    DioException e, {
    required String fallback,
    required String action,
  }) {
    final errorData = e.response?.data;

    if (errorData is Map<String, dynamic>) {
      final errorText = errorData['error']?.toString() ?? '';
      if (errorText.toLowerCase().contains('missing api key')) {
        return 'Онлайн $action отклонен: missing_api_key (проверьте x-api-key)';
      }
      if (errorText.isNotEmpty) {
        return 'Онлайн $action отклонен: $errorText';
      }
    }

    return fallback;
  }
}
