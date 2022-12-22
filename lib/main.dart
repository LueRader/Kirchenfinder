import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirche/widgets/ListPage.dart';
import 'package:kirche/model/church.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<Church> get getChurches {
    return [
      Church(
        name: 'N',
        streetName: 'SN',
        number: '1',
        zip: '12345',
        state: 'A',
        lat: 1.0,
        lon: 1.0,
      ),
      Church(
        name: 'Na',
        streetName: 'StN',
        number: '2',
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
            title: 'Flutter Demo Home Page',
            churches: getChurches,
        ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.churches});

  final String title;
  final List<Church> churches;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Colors.black,
        inactiveColor: Colors.black.withAlpha(80),
        items: const [
          BottomNavigationBarItem(
            label:'Liste',
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem(
            label:'Karte',
            icon: Icon(Icons.pin_drop),
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) {
          return CupertinoPageScaffold(child: ListPage(churches: widget.churches));
        });
      },
    );
  }
}
