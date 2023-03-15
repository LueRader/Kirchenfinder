import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kirche/model/church.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../ChurchProvider.dart';
import '../model/visit.dart';

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

  void _removeImagesFromList(List<int> idxs) {
    List<String> paths = [];
    _imageFileList!.asMap().forEach(
        (idx,element) {
          if (idxs.contains(idx)) {
            paths.add(element.path);
          }
        });
    _imageFileList!.removeWhere((e) => paths.contains(e.path));
  }

  Future<Directory> _getSavePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return await Directory("${documentsDirectory.path}/${widget.churchId}/${widget.visitId}").create(recursive: true);
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
        child: _selectionActive ? Transform.scale(
            scale: 0.9,
            child: Stack(alignment: Alignment.center,fit: StackFit.expand,children: <Widget>[
              img,
              Opacity(
                opacity: 0.5,
                child: Container(
                  color: Colors.black,
                ),
              ),
              Align(
                widthFactor: 0.1,
                heightFactor: 0.1,
                alignment: Alignment.topLeft,
                child: Icon(_selectedImages.contains(idx) ? Icons.check_circle : Icons.circle_outlined, color: Colors.white,),
              )
            ],
            )
        ) : img,
    );
  }

  Widget _showGallery(BuildContext context, List<XFile> imgs, int startIdx) {
    final PageController controller = PageController(initialPage: startIdx);
    return
      Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text("Aufnahmen"),
          actions: [
            IconButton(
                onPressed: () {
                  print(controller.page);
                },
                icon: const Icon(Icons.share))
          ],
        ),
        body: PageView.builder(
            controller: controller,
            itemCount: _imageFileList!.length,
            itemBuilder: (BuildContext context, int idx) {
              return SizedBox.expand(
                child: InteractiveViewer(
                  panEnabled: false,
                  minScale: 1.0,
                  maxScale: 2.5,
                  child: Image.file(File(imgs[idx].path)),
                ),
              );
            }),
      );
  }

  PreferredSizeWidget? _createAppBar(BuildContext context) {
    return _selectionActive ?
        AppBar(
          title: const Text('Aufnahmen löschen'),
          leading: IconButton(onPressed: () {
            setState(() {
              _selectedImages = [];
              _selectionActive = false;
            });
          }, icon: const Icon(Icons.close)
          ),
          actions: [
            IconButton(onPressed: () {
              List<File> imgFiles = _imageFileList!.asMap().entries
                  .where((e) => _selectedImages.contains(e.key))
                  .map((e) => File(e.value.path)).toList();
              setState(() {
                _removeImagesFromList(_selectedImages);
                _selectedImages = [];
                _selectionActive = false;
              });
              for(File imgFile in imgFiles) {
                imgFile.deleteSync();
              }
            }, icon: const Icon(Icons.delete)
            )
          ],
        )
        : AppBar(
      backgroundColor: Colors.black12,
      title: const Text('Besuch verzeichnen'),
      leading: const BackButton(
        color: Colors.black,
      ),
      actions: const [
      ],
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
      appBar: _createAppBar(context),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            DateFormat.yMd('de_DE').format(_visit.timestamp),
            style: const TextStyle(fontWeight: FontWeight.bold,),
            textScaleFactor: 2.0,

          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Aufnahmen',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold,),
            ),
          ],
        ),
        _imageFileList!.isEmpty ?
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Noch keine Aufnahmen'),
          ]
        )
        : Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                padding: const EdgeInsets.all(2),
                key: UniqueKey(),
                itemCount: _imageFileList!.length,
                itemBuilder: (BuildContext context, int idx) {
                  return _createImageTile(context, idx);
                }
                )
        )
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
                XFile? img = await _picker.pickImage(source: ImageSource.camera);
                if(img != null) {
                  Directory path = await _getSavePath();
                  String fullSaveName = "${path.path}/${DateTime
                      .now()
                      .millisecondsSinceEpoch}.jpg";
                  print(fullSaveName);
                  await img.saveTo(fullSaveName);
                  setState(() {
                    _addImagesToList([XFile(fullSaveName)]);
                  });
                }
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