import 'package:flutter/material.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/widgets/DetailPage.dart';
import 'package:path/path.dart';

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
      leading: AspectRatio(
          aspectRatio: 1,
          child: Image(image: AssetImage(join('assets',church.thumbnail))),
      ),
      title: Text(
        church.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        church.place,
        style: const TextStyle(color: Colors.black),
      ),
      trailing:
      const Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => DetailPage(churchId: church.id)));
      },
    );

    Material makeCard(Church church) => Material(
        child: makeListTile(church),
    );

    final makeBody = ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.churches.length,
        separatorBuilder: (_,__) => const Divider(height: 8,),
        itemBuilder: (BuildContext context, int index) {
          return makeCard(widget.churches[index]);
        },
    );

    return Scrollbar(
        thickness: 6.0,
        radius: const Radius.circular(34.0),
        child: makeBody
    );
  }
}
