import 'dart:io';

import 'package:path_provider/path_provider.dart';

class VisitImage {
  int id;
  int visitId;
  String savepath;
  DateTime takenAt;

  VisitImage({
    required this.id,
    required this.visitId,
    required this.savepath,
    required this.takenAt,
  });

  VisitImage.fromMap(Map<String, dynamic> res) :
        id = res['id'],
        visitId = res['visitId'],
        savepath = res['savepath'],
        takenAt = res['takenAt'];

  VisitImage.fromTaken(String path, int vid) :
      id = 0,
      visitId = vid,
      savepath = path,
      takenAt = DateTime.now();


  Map<String,Object?> toMap() {
    return {
      'id' : id,
      'visitId' : visitId,
      'savepath' : savepath,
      'takenAt' : takenAt,
    };
  }
}