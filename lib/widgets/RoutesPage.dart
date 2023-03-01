import 'package:flutter/material.dart';
import 'package:kirche/ChurchProvider.dart';
import 'package:kirche/DatabaseHelper.dart';
import 'package:kirche/model/ChurchRoute.dart';
import 'package:kirche/widgets/ListPage.dart';
import 'package:kirche/widgets/MapPage.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../model/church.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});


  @override
  _RoutesPageState createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {

  void initState() {
    super.initState();
  }

  Future<List<ChurchRoute>> _getRoutes() async {
    return await DatabaseHelper().loadRoutes();
  }

  Widget _makeRouteTile(BuildContext context, ChurchRoute route) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Image(image: AssetImage(join('assets',route.thumbnail))),
      ),
      title: Text(
        route.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => RoutePage(route: route)));
      },
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getRoutes(),
        builder: (BuildContext context, AsyncSnapshot<List<ChurchRoute>> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if(snapshot.hasError) {
              return const Text("Routen konnten nicht geladen werden.");
            }
            return ListView.separated(
                itemBuilder: (BuildContext context, int idx) {
                  _makeRouteTile(context, snapshot.data![idx]);
                },
                shrinkWrap: true,
                separatorBuilder: (_,__) => const Divider(height: 8,),
                itemCount: snapshot.data!.length
            );
          }
        }
    );
  }
}

class RoutePage extends StatefulWidget {
  const RoutePage({super.key, required this.route});

  final ChurchRoute route;

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {

  bool _showMap = false;
  List<Church> _routeChurches = [];

  List<Widget> _buildActionButtons(BuildContext context) {
    List<Widget> actions = <Widget>[];
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
    actions.add(
        IconButton(
          onPressed: () {
            setState(() {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => RouteInfo(churchId: church.id)));
            });
          },
          icon: () {
            return const Icon(Icons.info, semanticLabel: "Zur Routeninformation wechseln.",);
          }(),
        )
    );
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    _routeChurches = Provider.of<ChurchProvider>(context).getChurchesByIds(widget.route.churchIds);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: !_showMap ? ListPage(
        churches: _routeChurches,
      ) : MapPage(
          churches: _routeChurches,
      ),
    );
  }
}

