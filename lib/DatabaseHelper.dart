import 'dart:async';
import 'package:kirche/model/church.dart';
import 'package:kirche/model/visit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model/visitimage.dart';

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
      join(path, 'church_finder.db'),
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
          """);
        await database.execute(
          """
            CREATE TABLE visits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              churchId INTEGER NOT NULL,
              timestamp DATETIME NOT NULL
            );
          """
        );
        await database.execute(
          """
            CREATE TABLE visits_images (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              visitId INTEGER NOT NULL,
              savepath TEXT NOT NULL,
              takenAt DATETIME NOT NULL
            );
          """
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

  Future<Map<int,List<VisitImage>>> loadVisitImages() async {
    final List<Map<String,Object?>> visitImagesQueryRes = await db.query('visits_images');
    Map<int,List<VisitImage>> visitImages = {};
    for (var vi in visitImagesQueryRes) {
      VisitImage visitImage = VisitImage.fromMap(vi);
      visitImages.update(visitImage.visitId, (vis) => [...vis, visitImage], ifAbsent: () => [visitImage] );
    }
    return visitImages;
  }

  Future<int> upsertVisitImage(VisitImage vi) async {
    Map<String, Object?> vis = vi.toMap();
    if(vis['id'] == 0) vis.remove('id');
    return await db.insert('visit_images', vi.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteVisitImage(int id) async {
    return await db.delete('visits_images', where: "id = ?", whereArgs: [id]);
  }
  
  Future<Map<int,List<Visit>>> loadVisits() async {
    final List<Map<String,Object?>> visitQueryRes = await db.query('visits');
    Map<int,List<Visit>> visits = {};
    Map<int,List<VisitImage>> images = await loadVisitImages();
    for (var v in visitQueryRes) {
      v['images'] = images[v['id']] ?? [];
      Visit visit = Visit.fromMap(v);
      visits.update(visit.churchId, (vs) => [...vs, visit], ifAbsent: () => [visit] );
    }
    return visits;
  }

  Future<int> upsertVisit(Visit v) async {
    Map<String, Object?> vis = v.toMap();
    if(vis['id'] == 0) vis.remove('id');
    return await db.insert('visit_images', v.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteVisit(int id) async {
    return await db.delete('visits', where: "id = ?", whereArgs: [id]);
  }
}