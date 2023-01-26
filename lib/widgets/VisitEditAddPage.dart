import 'package:flutter/material.dart';
import 'package:kirche/model/church.dart';

import '../model/visit.dart';
import '../model/visitimage.dart';

class VisitEditAddPage extends StatefulWidget {
  const VisitEditAddPage({super.key, required this.church, this.visitId = 0});

  final Church church;
  final int visitId;

  @override
  _VisitEditAddPageState createState() => _VisitEditAddPageState();
}

class _VisitEditAddPageState extends State<VisitEditAddPage> {

  late DateTime timestamp = DateTime.now();
  late List<VisitImage> visitImages = widget.church.visits[widget.visitId].images;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text('Besuch verzeichnen'),
        leading: const BackButton(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if(widget.visitId == 0) {
                  Map<String, dynamic> visit = {};
                  visit.putIfAbsent('id', () => widget.visitId);
                  visit.putIfAbsent('churchId', () => widget.church.id);
                  visit.putIfAbsent('timestamp', () => timestamp);
                  visit.putIfAbsent('images', () => visitImages);
                }
              });
            },
            icon: Icon(Icons.save, semanticLabel: "Besuch speichern",),
          )
        ],
      ),
      body: Center(
        child: DatePickerDialog(
          initialDate: DateTime.now(),
          firstDate: DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch-20160*60*1000),
          lastDate: DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch+20160*60*1000),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt, semanticLabel: "Foto aufnehmen.",),
        onPressed: () {
          /*Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => VisitAddPage(church: church)));*/
        },
      ),
    );
  }
}