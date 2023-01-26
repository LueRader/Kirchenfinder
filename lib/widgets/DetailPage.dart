import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/model/visit.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'VisitEditAddPage.dart';
import 'VisitDetailPage.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.church});

  final Church church;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {


  @override
  Widget build(BuildContext context) {
    Widget makeVisit(Visit visit) {
      return ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: const Icon(Icons.ac_unit),
        title: Text(
          DateFormat.yMd('de_DE').format(visit.timestamp),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              const WidgetSpan(
                  child: Icon(Icons.camera_alt_outlined),
              ),
              TextSpan(
                text: "${visit.images.length} Aufnahmen",
              )
            ]
          )
        ),
        trailing:
        const Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => VisitDetailPage(visit: visit)));
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
        itemCount: widget.church.visits.length,
        itemBuilder: (BuildContext context, int idx) {
          return makeVisit(widget.church.visits[idx]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, semanticLabel: "Besuch hinzufügen.",),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => VisitEditAddPage(church: widget.church)));
        },
      ),
    );
  }
}
