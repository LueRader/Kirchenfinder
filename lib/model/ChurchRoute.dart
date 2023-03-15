import 'package:collection/collection.dart';

class ChurchRoute {
  int id;
  String category;
  String difficulty;
  String thumbnail;
  String phrase;
  String name;
  String info;
  List<int> churchIds;

  ChurchRoute({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.thumbnail,
    required this.phrase,
    required this.name,
    required this.info,
    required this.churchIds,
  });

  ChurchRoute.fromMap(Map<String, dynamic> res) :
        id = res['id'],
        category = res['category'],
        difficulty = res['difficulty'],
        thumbnail = res['thumbnail'],
        phrase = res['phrase'],
        name = res['name'],
        info = res['info'],
        churchIds = List<int>.from((res['churchIds']
            .split(',')
            ..sort(compareNatural))
            .map((e) => int.parse(e.split(":")[1]))
            .toList());
}