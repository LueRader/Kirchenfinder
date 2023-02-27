import 'package:kirche/model/visit.dart';

class Church {
  int id;
  String? category;
  String? form;
  String? region;
  String? denom;
  double lat;
  double lon;
  String? arch;
  String? material;
  String? link;
  String name;
  String? phone;
  String place;
  String? sketchimage;
  String thumbnail;
  String? heading;
  String? info;
  String? history;
  String? longinfo;
  String? reformation;
  String? spiritual;
  String? stamp;

  Church({
    required this.id,
    this.category,
    this.form,
    this.region,
    this.denom,
    required this.lat,
    required this.lon,
    this.arch,
    this.material,
    this.link,
    required this.name,
    this.phone,
    required this.place,
    this.sketchimage,
    required this.thumbnail,
    this.heading,
    this.info,
    this.history,
    this.longinfo,
    this.reformation,
    this.spiritual,
    this.stamp,
  });

  Church.fromMap(Map<String, dynamic> res) :
        id = res['id'],
        category = res['category'],
        form = res['form'],
        region = res['region'],
        denom = res['denom'],
        lat = res['lat'],
        lon = res['lon'],
        arch = res['arch'],
        material = res['material'],
        link = res['link'],
        name = res['name'],
        phone = res['phone'],
        place = res['place'],
        sketchimage = res['sketchimage'],
        thumbnail = res['thumbnail'],
        heading = res['heading'],
        info = res['info'],
        history = res['history'],
        longinfo = res['longinfo'],
        reformation = res['reformation'],
        spiritual = res['spiritual'],
        stamp = res['stamp'];


  Map<String,Object?> toMap() {
    return {
      'id' : id,
      'category' : category,
      'form' : form,
      'region' : region,
      'denom' : denom,
      'lat' : lat,
      'lon' : lon,
      'name' : name,
    };
  }
}