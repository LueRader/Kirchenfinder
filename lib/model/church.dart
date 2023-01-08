class Church {
  int id;
  String name;
  String streetName;
  String streetNumber;
  String zip;
  String state;
  double lat;
  double lon;

  Church({
    required this.id,
    required this.name,
    required this.streetName,
    required this.streetNumber,
    required this.zip,
    required this.state,
    required this.lat,
    required this.lon});

  Church.fromMap(Map<String, dynamic> res) :
        id = res['id'],
        name = res['name'],
        streetName = res['streetName'],
        streetNumber = res['streetNumber'],
        zip = res['zip'],
        state = res['state'],
        lat = res['lat'],
        lon = res['lon'];

  Map<String,Object?> toMap() {
    return {
      'id' : id,
      'name' : name,
      'streetName' : streetName,
      'number' : streetNumber,
      'zip' : zip,
      'state' : state,
      'lat' : lat,
      'lon' : lon
    };
  }
}