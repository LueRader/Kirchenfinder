import 'package:kirche/DatabaseHelper.dart';
import 'package:kirche/model/visitimage.dart';

class Visit {
  int id;
  int churchId;
  DateTime timestamp;
  //List<VisitImage> images;

  Visit({
    required this.id,
    required this.churchId,
    required this.timestamp,
    //required this.images,
  });

  Visit.fromMap(Map<String, dynamic> res) :
        id = res['id'],
        churchId = res['churchId'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(res['timestamp']);
        //images = res['images'];

  Map<String,Object?> toMap() {
    return {
      'id' : id,
      'churchId' : churchId,
      'timestamp' : timestamp.millisecondsSinceEpoch,
    };
  }

  Future<int> saveVisit() async {
    int id = await DatabaseHelper().upsertVisit(this);
    return id;
  }

  Future<int> deleteVisit() async {
    int id = await DatabaseHelper().deleteVisit(this.id);
    return id;
  }
}