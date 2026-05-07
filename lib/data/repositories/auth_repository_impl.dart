// Слой: data | Назначение: реализация AuthRepository через локальные источники данных

import 'dart:math';

import 'package:dio/dio.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localDatasource, this._remoteDatasource);

  final AuthLocalDatasource _localDatasource;
  final AuthRemoteDatasource _remoteDatasource;

  static String _localToken() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Future<User> login({required String email, required String password}) async {
    String token;
    try {
      token = await _remoteDatasource.login(email: email, password: password);
    } on DioException catch (e) {
      // Сервер ответил — значит сеть есть, но данные неверны → не делаем fallback
      if (e.response != null) rethrow;
      // Нет связи — пробуем локальный логин
      final localUser = await _localDatasource.login(email: email, password: password);
      token = _localToken();
      await _localDatasource.saveSession(localUser, token: token);
      return localUser;
    }
    final existingUser = await _localDatasource.findByEmail(email);
    final user = existingUser ??
        await _localDatasource.createUser(
          name: email.split('@').first,
          email: email,
          password: password,
        );
    await _localDatasource.saveSession(user, token: token);
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    String token;
    try {
      token = await _remoteDatasource.register(email: email, password: password);
    } catch (_) {
      // reqres.in не принимает произвольные email — регистрируем локально
      token = _localToken();
    }

    final user = await _localDatasource.register(
      name: name,
      email: email,
      password: password,
    );
    await _localDatasource.saveSession(user, token: token);
    return user;
  }

  @override
  Future<User?> checkSession() {
    return _localDatasource.loadSession();
  }

  @override
  Future<void> logout() {
    return _localDatasource.clearSession();
  }
}
