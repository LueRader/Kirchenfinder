import 'dart:async';

import 'package:kirche/model/church.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  late Database db;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<void> initDB() async {
    String path = await getDatabasesPath();
    db = await openDatabase(
      join(path, 'users_demo.db'),
      onCreate: (database, version) async {
        await database.execute(
          """
            CREATE TABLE churches (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              streetName TEXT NOT NULL,
              number TEXT NOT NULL,
              zip TEXT NOT NULL,
              state TEXT NOT NULL,
              lat DECIMAL(10,5) NOT NULL,
              lon DECIMAL(10,5) NOT NULL
            );
            Create Table visits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              church_id INTEGER NOT NULL,
              visit_timestamp DATETIME NOT NULL
            );
          """,
        );
      },
      version: 1,
    );
  }

  Future<int> insertChurch(Church church) async {
    return await db.insert('churches', church.toMap());
  }

  Future<int> upsertChurch(Church church) async {
    return await db.insert('churches', church.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateChurch(Church church) async {
    return await db.update('churches', church.toMap(),where: "id = ?", whereArgs: [church.id]);
  }

  Future<List<Church>> loadChurches() async {
    final List<Map<String,Object?>> queryRes = await db.query('churches');
    return queryRes.map((c) => Church.fromMap(c)).toList();
  }

  Future<int> deleteChurch(int id) async {
    return await db.delete('churches', where: "id = ?", whereArgs: [id]);
  }
}