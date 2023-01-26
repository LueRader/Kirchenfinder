import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirche/model/visit.dart';
import 'package:kirche/widgets/ListPage.dart';
import 'package:kirche/widgets/MapPage.dart';
import 'package:kirche/DatabaseHelper.dart';
import 'package:kirche/model/church.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:kirche/model/visitimage.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late DatabaseHelper dbHelper = DatabaseHelper();
  dbHelper.initDB().whenComplete(() async {
    List<Church> churches = [];
    Map<int, List<Visit>> visits = {};
    Map<int,List<VisitImage>> visitImages = {};
    try {
      churches = await dbHelper.loadChurches();
      visits = await dbHelper.loadVisits();
      visitImages = await dbHelper.loadVisitImages();
    } catch(e) {
      print("Error");
    }

    for (var ch in churches) {
      ch.visits = visits[ch.id] ?? [];
      for (var vi in ch.visits) { vi.images = visitImages[vi.id] ?? []; }
    }
    runApp(const MyApp());
  });
  //runApp(const MyApp());
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  bool _showMap = false;
  late List<Church> _filteredChurches;
  late SearchBar _searchBar;
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _filteredChurches = widget.churches;
    _searchBar = SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onChanged: onSubmitted,
        onCleared: () {
          setState(() {
            _filteredChurches = widget.churches;
          });
        },
        onClosed: () {
        setState(() {
          _filteredChurches = widget.churches;
        });
      },
    );
  }

  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actions = [];
    actions.add(
      IconButton(
        onPressed: () {
          setState(() {
            _showMap = !_showMap;
          });
        },
        icon: () {
          if(!_showMap) return const Icon(Icons.map, semanticLabel: "Zur Kartenansicht wechseln.",);
          return const Icon(Icons.list, semanticLabel: "Zur Listenansicht wechseln.",);
        }(),
      )
    );
    if(_searchActive) {
      actions.add(
        IconButton(onPressed: () {
          setState(() {
            _searchActive = false;
            _filteredChurches = widget.churches;
          });
        }, icon: const Icon(Icons.search_off, semanticLabel: "Suche löschen",),
        )
      );
    } else {
      actions.add(_searchBar.getSearchAction(context));
    }
    return actions;
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: const Text('Search Bar Demo'),
        actions: buildActionButtons(context));
  }

  void onSubmitted(String value) {
    setState(() {
      _searchActive = true;
      _filteredChurches = widget.churches.where((church) => church.name.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _searchBar.build(context),
       body: AnimatedCrossFade(
         firstChild: ListPage(churches: _filteredChurches),
         secondChild: MapPage(churches: _filteredChurches),
         duration: const Duration(milliseconds: 300),
         crossFadeState: _showMap
           ? CrossFadeState.showSecond
           : CrossFadeState.showFirst,
       ),
    );
  }
}
