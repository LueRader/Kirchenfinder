import 'dart:io';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kirche/ChurchProvider.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/model/visit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:kirche/DatabaseHelper.dart';
import 'VisitEditAddPage.dart';
import 'VisitDetailPage.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.churchId});

  final int churchId;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  late Church _church;
  late List<Visit> _visits;

  @override
  void initState() {

    super.initState();
    initializeDateFormatting();
  }


  @override
  Widget build(BuildContext context) {

    _visits = Provider.of<ChurchProvider>(context, listen: true).getVisits(widget.churchId);
    _church = Provider.of<ChurchProvider>(context, listen: true).getChurch(widget.churchId);

    Widget makeChurchRow(String prop, String val, {String href = ""}) {
      return Row(
        children: [
          Text(
            prop,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Link(val)
          ),
        ],
      );
    }

    Widget makeChurchInfo() {
      return Row();
    }

    Widget makeVisit(int idx) {
      return ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: const Icon(Icons.ac_unit),
        title: Text(
          DateFormat.yMd('de_DE').format(_visits[idx].timestamp),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
          text: const TextSpan(
            children: [
              WidgetSpan(
                  child: Icon(Icons.camera_alt_outlined),
              ),
              TextSpan(
                text: "Aufnahmen",
              )
            ]
          )
        ),
        trailing:
        const Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => VisitEditAddPage(churchId: widget.churchId, visitId: _visits[idx].id,)));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text('Detail'),
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      body: ListView.builder(
        itemCount: _visits.length,
        itemBuilder: (BuildContext context, int idx) {
          return Dismissible(
            key: Key(_visits[idx].id.toString()),
            background: Container(color: Colors.redAccent,),
            direction: DismissDirection.endToStart,
            onDismissed: (DismissDirection direction) {
              _visits[idx].deleteVisit().then((res) {
                if(res == 1) {
                  Provider.of<ChurchProvider>(context, listen: false).removeVisit(widget.churchId, _visits[idx].id);
                }
              });
            },
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Bestätigung"),
                    content: const Text("Sind Sie sicher, dass Sie diesen Besuch löschen wollen?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("LÖSCHEN")
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("ABBRECHEN"),
                      ),
                    ],
                  );
                },
              );
            },
            child: makeVisit(idx),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, semanticLabel: "Besuch hinzufügen.",),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => VisitEditAddPage(churchId: widget.churchId)));
        },
      ),
    );
  }
}
