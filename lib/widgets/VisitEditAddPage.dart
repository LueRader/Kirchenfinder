import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kirche/main.dart';
import 'package:kirche/model/church.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _selectionActive = false;
  List<int> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.visitId != 0) {
      _visit = Provider.of<ChurchProvider>(context, listen: false)
          .getVisits(widget.churchId)
          .where((v) => v.id == widget.visitId)
          .toList()[0];
    } else {
      _visit = Visit.fromMap({
        'id': 0,
        'churchId': widget.churchId,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
    }
    _getImagesFromFolder();

  }

  void addVisitToChurch(BuildContext context, Visit v) {
    Provider.of<ChurchProvider>(context, listen: false)
        .addVisit(widget.churchId, v);
  }

  void updateVisit(BuildContext context, Visit v) {
    Provider.of<ChurchProvider>(context, listen: false)
        .updateVisit(widget.churchId, v);
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

  void _addImagesToList(List<XFile> imgs) {
    _imageFileList!.addAll(imgs);
  }

  void _removeImagesFromList(List<XFile> imgs) {
    _imageFileList!.removeWhere(
        (element) => imgs.map((e) => e.path).toList().contains(element.path));
  }

  Future<Directory> _getSavePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return await Directory("$documentsDirectory/${widget.churchId}/${widget.visitId}").create(recursive: true);
  }

  Future<void> _getImagesFromFolder() async {
    Directory path = await _getSavePath();
    setState(() {
      _addImagesToList(path.listSync().map((e) => XFile(e.path)).toList());
    });
  }

  Widget _createImageTile(BuildContext context, int idx) {
    Widget img = Image.file(
      File(_imageFileList![idx].path),
      fit: BoxFit.fill,
      alignment: Alignment.center,
    );
    return GestureDetector(
        onLongPress: () {
          if (!_selectionActive) {
            setState(() {
              _selectionActive = true;
              _selectedImages = <int>[idx];
            });
          }
        },
        onTap: () {
          if (_selectionActive) {
            setState(() {
              _selectedImages.add(idx);
            });
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => _showGallery(context, _imageFileList!, idx)));
          }
        },
        child: _selectionActive ?  Stack(children: <Widget>[
          img,
          Align(
            widthFactor: 0.1,
            heightFactor: 0.1,
            alignment: Alignment.topLeft,
            child: Icon(_selectedImages.contains(idx) ? Icons.check_circle : Icons.circle_outlined),
          )
        ]) : img,
    );
  }

  Widget _showGallery(BuildContext context, List<XFile> imgs, int startIdx) {
    final PageController controller = PageController(initialPage: startIdx);
    return
      Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text("Bild ${controller.page}/${imgs.length}"),
          actions: [
            IconButton(
                onPressed: () {

                },
                icon: const Icon(Icons.share))
          ],
        ),
        body: PageView.builder(
            controller: controller,
            itemBuilder: (BuildContext context, int idx) {
              return SizedBox.expand(
                child: Image.file(File(imgs[idx].path)),
              );
            }),
      );
  }

  Widget _showCapturePreview(BuildContext context, XFile img) {
    return Scaffold(
      body: Stack(
        children: [
          Image(
            image: Image.file(File(img.path)).image,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    icon: const Icon(Icons.cancel_outlined)
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.cancel_outlined)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //_church = Provider.of<ChurchProvider>(context, listen: false).getChurch(widget.churchId);
    storeVisit().then((id) {
      if (id != 0 && _visit.id == 0) {
        _visit.id = id;
        addVisitToChurch(context, _visit);
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
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('ABC'),
          IconButton(
            icon: const Icon(Icons.date_range),
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
                    if (id != 0) {
                      updateVisit(context, _visit);
                    }
                  });
                });
              });
            },
          ),
        ]),
        Row(
          children: const [
            Text('Aufnahmen', textAlign: TextAlign.center, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        ),
        _imageFileList!.isEmpty ?
        Center(
          child: Row(
            children: const <Widget>[
              Text('Noch keine Aufnahmen'),
          ]
          ),
        )
        : GridView.builder(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int idx) {
              return _createImageTile(context, idx);
            })
      ]),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        openCloseDial: isDialOpen,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.camera_alt),
              onTap: () async {
                bool save = true;
                XFile? img;
                do {
                  img = await _picker.pickImage(source: ImageSource.camera);
                  if(img != null) {
                    if(!mounted) return;
                    save = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            _showCapturePreview(context, img!)));
                  } else {
                    return;
                  }
                } while(!save);
                Directory path = await _getSavePath();
                String fullSaveName = "${path.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
                await img.saveTo(fullSaveName);
                setState(() {
                  _addImagesToList([XFile(fullSaveName)]);
                });
              }),
          SpeedDialChild(
              child: const Icon(Icons.image),
              onTap: () async {
                final List<XFile> imgs = await _picker.pickMultiImage();
                List<XFile> saveImgs = [];
                Directory path = await _getSavePath();
                int idx = DateTime.now().millisecondsSinceEpoch;
                for(final img in imgs) {
                  String fullSaveName = "${path.path}/idx.jpg";
                  await img.saveTo(fullSaveName);
                  saveImgs.add(XFile(fullSaveName));
                  idx++;
                }
                setState(() {
                  _addImagesToList(saveImgs);
                });
              })
        ],
      ),
    );
  }
}