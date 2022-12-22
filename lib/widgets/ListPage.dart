import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/widgets/DetailPage.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.churches});

  final List<Church> churches;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(Church church) => ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: const Icon(
            Icons.ac_unit,
            color: Colors.black
      ),
      title: Text(
        church.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        church.streetName,
        style: const TextStyle(color: Colors.black),
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
      onTap: () {
        Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (context) => DetailPage(church: church)));
      },
    );

    Material makeCard(Church church) => Material(
        child: makeListTile(church),
    );

    final makeBody = ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: false,
        itemCount: widget.churches.length,
        separatorBuilder: (_,__) => const Divider(height: 8,),
        itemBuilder: (BuildContext context, int index) {
          return makeCard(widget.churches[index]);
        },
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Liste'),
      ),
      backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: makeBody
      ),
    );
  }
}
