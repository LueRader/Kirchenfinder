import 'package:flutter/cupertino.dart';

import 'DatabaseHelper.dart';
import 'model/church.dart';
import 'model/visit.dart';

class ChurchProvider extends ChangeNotifier {
  Map<int,Church> _churches = {};
  Map<int,List<Visit>> _visits = {};

  void setChurches(Map<int,Church> churches) {
    _churches = churches;
  }

  void addVisit(int churchId, Visit v) {
    _visits[churchId] = [..._visits[churchId] ?? [], v];
    notifyListeners();
  }

  void updateVisit(int churchId, Visit v) {
    _visits[churchId]![_visits[churchId]!.indexWhere((vi) => v.id == vi.id)] = v;
    notifyListeners();
  }

  void removeVisit(int churchId, int visitId) {
    _visits[churchId] = _visits[churchId]!.where((v) => v.id != visitId).toList();
    notifyListeners();
  }

  Church getChurch(int id) {
    return _churches[id]!;
  }

  List<Visit> getVisits(int churchId) {
    return _visits[churchId] ?? [];
  }
  
  List<Church> getChurchesByIds(List<int> ids) {
    return _churches.entries.where((c) => ids.contains(c.key)).map((e) => e.value).toList();
  }

  Map<int,Church> get getChurches {
    if(_churches.isEmpty) {
      late DatabaseHelper dbHelper = DatabaseHelper();
      dbHelper.initDB().whenComplete(() async {
        List<Church> churches = [];
        Map<int, List<Visit>> visits = {};
        try {
          churches = await dbHelper.loadChurches();
          visits = await dbHelper.loadVisits();
        } catch (e) {
          print("Error $e");
        }

        _visits = visits;
        _churches = { for (var c in churches) c.id : c };
        notifyListeners();
      });
    }
    return _churches;
  }
}