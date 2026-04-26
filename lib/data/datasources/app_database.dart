// Слой: data | Назначение: Drift AppDatabase — singleton, таблица Users

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// UserRow — Drift-сгенерированный класс (не конфликтует с domain User)
extension UserRowMapper on UserRow {
  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        createdAt: createdAt,
      );
}
