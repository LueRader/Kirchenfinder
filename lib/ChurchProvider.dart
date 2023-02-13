import 'package:flutter/cupertino.dart';

import 'DatabaseHelper.dart';
import 'model/church.dart';
import 'model/visit.dart';

List<Church> getChs() {
  return [
    Church(
      id: 1,
      name: 'N',
      streetName: 'SN',
      streetNumber: '1',
      zip: '12345',
      state: 'A',
      lat: 53.7398629,
      lon: 13.0813882,
    ),
    Church(
      id: 2,
      name: 'Na',
      streetName: 'StN',
      streetNumber: '2',
      zip: '23456',
      state: 'B',
      lat: 53.6033576,
      lon: 12.2021056,
    ),
  ];
}

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

        for (var ch in churches) {
          ch.visits = visits[ch.id] ?? [];
        }
        _visits = visits;
        _churches = { for (var c in churches) c.id : c };
        notifyListeners();
      });
    }
    return _churches;
  }
}