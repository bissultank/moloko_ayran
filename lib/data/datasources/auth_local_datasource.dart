// Слой: data | Назначение: локальный источник данных авторизации (Drift + SharedPreferences)

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import 'app_database.dart';

class AuthLocalDatasource {
  AuthLocalDatasource(this._db);

  final AppDatabase _db;

  Future<User?> findByEmail(String email) async {
    final userRow = await (_db.select(_db.users)
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();
    return userRow?.toEntity();
  }

  Future<User> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final id = await _db.into(_db.users).insert(
          UsersCompanion.insert(
            name: name,
            email: email,
            password: password,
            createdAt: DateTime.now(),
          ),
        );

    final userRow = await (_db.select(_db.users)..where((u) => u.id.equals(id)))
        .getSingle();
    return userRow.toEntity();
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final existing = await (_db.select(_db.users)
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();

    if (existing != null) {
      throw Exception('Пользователь с email $email уже существует');
    }

    return createUser(name: name, email: email, password: password);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final userRow = await (_db.select(_db.users)
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();

    if (userRow == null) {
      throw Exception('Пользователь не найден');
    }

    if (userRow.password != password) {
      throw Exception('Неверный пароль');
    }

    return userRow.toEntity();
  }

  Future<void> saveSession(User user, {required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.kSessionKey, user.id);
    await prefs.setString(AppConstants.kUserEmailKey, user.email);
    await prefs.setString(AppConstants.kSessionTokenKey, token);
  }

  Future<User?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.kSessionKey);
    final token = prefs.getString(AppConstants.kSessionTokenKey);

    if (userId == null || token == null || token.isEmpty) return null;

    final userRow = await (_db.select(_db.users)
          ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();

    return userRow?.toEntity();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kSessionKey);
    await prefs.remove(AppConstants.kUserEmailKey);
    await prefs.remove(AppConstants.kSessionTokenKey);
  }
}
