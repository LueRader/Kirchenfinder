import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirche/widgets/ListPage.dart';
import 'package:kirche/DatabaseHelper.dart';
import 'package:kirche/model/church.dart';

void main() {
  late DatabaseHelper dbHelper = DatabaseHelper();
  dbHelper.initDB().whenComplete(() => () async {
    List<Church> churches = await dbHelper.loadChurches();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<Church> get getChurches {
    return [
      Church(
        id: 1,
        name: 'N',
        streetName: 'SN',
        streetNumber: '1',
        zip: '12345',
        state: 'A',
        lat: 1.0,
        lon: 1.0,
      ),
      Church(
        id: 2,
        name: 'Na',
        streetName: 'StN',
        streetNumber: '2',
        zip: '23456',
        state: 'B',
        lat: 2.0,
        lon: 2.0,
      ),
    ];
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        home: MyHomePage(
            churches: getChurches,
        ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.churches});

  final List<Church> churches;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;

  List<int> _filterList = [];

  List<Church> _getFilteredChurches() {
    return widget.churches.where((church) => _filterList.contains(church.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        thickness: 6.0,
        thicknessWhileDragging: 10.0,
        radius: const Radius.circular(34.0),
        radiusWhileDragging: const Radius.circular(34.0),
        child: ListPage(churches: _getFilteredChurches()),
      )
    );
  }
}
