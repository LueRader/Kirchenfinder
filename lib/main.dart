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
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'ChurchProvider.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(value: ChurchProvider(),)
      ],
      child: const MaterialApp(
          home: MyHomePage(
          ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _showMap = false;
  late List<Church> _filteredChurches;
  late SearchBar _searchBar;
  String _searchActive = '';


  @override
  void initState() {
    super.initState();
    _searchBar = SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onChanged: onSubmitted,
        onCleared: () {
          setState(() {
            _searchActive = '';
          });
        },
        onClosed: () {
        setState(() {
          _searchActive = '';
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
    if(_searchActive != '') {
      actions.add(
        IconButton(onPressed: () {
          setState(() {
            _searchActive = '';
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
        title: const Text('Kirchenfinder'),
        actions: buildActionButtons(context));
  }

  void onSubmitted(String value) {
    setState(() {
      _searchActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    _filteredChurches = Provider.of<ChurchProvider>(context).getChurches.entries
        .map((c) => c.value).toList()
        .where((church) => church.place.toLowerCase()
        .contains(_searchActive.toLowerCase())).toList();
    return Scaffold(
      appBar: _searchBar.build(context),
      body: !_showMap ? ListPage(churches: _filteredChurches) : MapPage(churches: _filteredChurches),
    );
  }
}
