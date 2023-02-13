import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kirche/main.dart';
import 'package:kirche/model/church.dart';
import 'package:provider/provider.dart';

import '../ChurchProvider.dart';
import '../model/visit.dart';
import '../model/visitimage.dart';
import 'CameraPage.dart';

class VisitEditAddPage extends StatefulWidget {
  const VisitEditAddPage({super.key, required this.churchId, this.visitId = 0});

  final int churchId;
  final int visitId;

  @override
  _VisitEditAddPageState createState() => _VisitEditAddPageState();
}

class _VisitEditAddPageState extends State<VisitEditAddPage> {

  late Church? _church;
  late Visit _visit;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFileList = [];
  ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if(widget.visitId != 0) {
      _visit = Provider.of<ChurchProvider>(context, listen: false).getVisits(widget.churchId).where((v) => v.id == widget.visitId).toList()[0];
    } else {
      _visit = Visit.fromMap(
          {'id': 0, 'churchId': widget.churchId, 'timestamp': DateTime
              .now()
              .millisecondsSinceEpoch});
    }
  }

  void addVisitToChurch(BuildContext context, Visit v) {
    Provider.of<ChurchProvider>(context, listen: false).addVisit(widget.churchId, v);
  }

  void updateVisit(BuildContext context, Visit v) {
    Provider.of<ChurchProvider>(context, listen: false).updateVisit(widget.churchId, v);
  }

  Future<int> storeVisit() async {
    int id = 0;
    try {
      id = await _visit.saveVisit();
    } catch (e) {
      print("Error: $e");
    }
    return id;
  }

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file);
          } else {
            _imageFileList = response.files;
          }
        });
    } else {
      //_retrieveDataError = response.exception!.code;
    }
  }


  @override
  Widget build(BuildContext context) {
    //_church = Provider.of<ChurchProvider>(context, listen: false).getChurch(widget.churchId);
    storeVisit().then((id) {
      if(id != 0 && _visit.id == 0) {
        _visit.id = id;
        addVisitToChurch(context,_visit);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text('Besuch verzeichnen'),
        leading: const BackButton(
          color: Colors.black,
        ),
        actions: const [
          /*IconButton(
            onPressed: () {
              setState(() {
                if(widget.visitId == 0) {
                  Map<String, dynamic> visit = {};
                  visit.putIfAbsent('id', () => widget.visitId);
                  visit.putIfAbsent('churchId', () => widget.churchId);
                  visit.putIfAbsent('timestamp', () => timestamp);
                }
              });
            },
            icon: Icon(Icons.save, semanticLabel: "Besuch speichern",),
          )*/
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ABC'),
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () {
                showDatePicker(
                    context: context,
                    initialDate: _visit.timestamp,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now())
                    .then((pickedDate) {
                  // Check if no date is selected
                  setState(() {
                    if (pickedDate == null) {
                      return;
                    }
                    _visit.timestamp = pickedDate;
                    storeVisit().then((id) {
                      if(id != 0) {
                        updateVisit(context, _visit);
                      }
                    });
                  });
                });
              },
            ),
          ]
        ),
      ),
      floatingActionButton: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              openCloseDial: isDialOpen,
              childPadding: const EdgeInsets.all(5),
              spaceBetweenChildren: 4,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.camera_alt),
                  onTap: () {

                  }
                ),
                SpeedDialChild(
                  child: const Icon(Icons.image),
                  onTap: () {

                  }
                )
              ],
          ),
    );
  }
}