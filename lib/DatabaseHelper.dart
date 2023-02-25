import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
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
    path = join(path,'church_finder.db');

    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('assets', 'churches.sqlite'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }
    db = await openDatabase(
      join(path, 'church_finder.db'),
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
    for (var v in visitQueryRes) {
      Visit visit = Visit.fromMap(v);
      visits.update(visit.churchId, (vs) => [...vs, visit], ifAbsent: () => [visit] );
    }
    return visits;
  }

  Future<int> upsertVisit(Visit v) async {
    Map<String, Object?> vis = v.toMap();
    if(vis['id'] == 0) vis.remove('id');
    return await db.insert('visits', vis, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteVisit(int id) async {
    return await db.delete('visits', where: "id = ?", whereArgs: [id]);
  }
}