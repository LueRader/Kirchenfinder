import 'package:kirche/model/visitimage.dart';

class Visit {
  int id;
  int churchId;
  DateTime timestamp;
  List<VisitImage> images;

  Visit({
    required this.id,
    required this.churchId,
    required this.timestamp,
    required this.images,
  });

  Visit.fromMap(Map<String, dynamic> res) :
        id = res['id'],
        churchId = res['churchId'],
        timestamp = res['timestamp'],
        images = res['images'];




  Map<String,Object?> toMap() {
    return {
      'id' : id,
      'churchId' : churchId,
      'timestamp' : timestamp,
    };
  }
}