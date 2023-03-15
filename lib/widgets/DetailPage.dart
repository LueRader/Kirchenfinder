import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:kirche/ChurchProvider.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/model/visit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:kirche/DatabaseHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MapPage.dart';
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
  bool _showMap = false;

  @override
  void initState() {

    super.initState();
    initializeDateFormatting();
  }

  Widget _makeDataRow(String prop, String val, {String href = "", String type = "https"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Text(
            prop,
            textScaleFactor: 1.4,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GestureDetector (
              onTap: () async {
                print("click");
                if(href != "") {
                  if (!await launchUrl(Uri(scheme: type, path: href))) throw 'Could not launch $href';
                }
              },
              child: Text(
                val,
                textScaleFactor: 1.2,
                style: TextStyle(color: href != "" ? Colors.indigo : Colors.black),
              )
          ),
        )
      ],
    );
  }

  List<Widget> _makeChurchData(BuildContext context) {
    List<Widget> res = <Widget>[];
    if(_church.phone != null) {
      res += (_makeSection(context, <Widget>[
        _makeDataRow("Telefon", _church.phone!, href: _church.phone!, type: "tel")
      ]));
    }
    if(_church.link != null) {
      res += (_makeSection(context, <Widget>[
        _makeDataRow("Link", _church.link!, href: _church.link!)
      ]));
    }
    res += (_makeSection(context, <Widget>[
      _makeDataRow("Architektur",_church.arch!.replaceAll(',','\n'))
    ]));
    if(_church.form != null) {
      res += (_makeSection(context, <Widget>[
        _makeDataRow("Bauform",_church.form!)
      ]));
    }
    res += (_makeSection(context, <Widget>[
      _makeDataRow("Region",_church.region!)
    ]));
    if(_church.category != null) {
      res += (_makeSection(context, <Widget>[
        _makeDataRow("Kategorie",_church.category!)
      ]));
    }
    res += (_makeSection(context, <Widget>[
      _makeDataRow("Nutzung",_church.denom!)
    ]));
    res += (_makeSection(context, <Widget>[
      _makeDataRow("Baumaterial",_church.material!.replaceAll(',','\n'))
    ]));
    return res;
  }

  Widget _makeVisit(int idx) {
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

  List<Widget> _makeVisitsList(BuildContext context) {
    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Flexible(
              child: Text(
                "Besuche",
                textScaleFactor: 1.5,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
          )
        ],
      ),
      ListView.builder(
        itemCount: _visits.length,
        shrinkWrap: true,
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
            child: _makeVisit(idx),
          );
        },
      ),
    ];
  }

  List<Widget> _makeTitle(BuildContext context) {
    return <Widget>[
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
                  _church.place,
                  textScaleFactor: 1.8,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
            )
          ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              child: Text(
                _church.name,
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
              )
          )
        ],
      ),
    ];
  }

  List<Widget>? _makeInfo(BuildContext context) {
    List<Widget> res = <Widget>[];
    if(_church.heading != null) {
      res.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
                  _church.heading!,
                  textScaleFactor: 1.5,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
            )
          ]
        ),
      );
      res.add(const SizedBox(height: 10.0));
    }
    if(_church.info != null) {
      res.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _church.info!,
              )
            )
          ],
        ),
      );
    }
    return res.isNotEmpty ? res : null;
  }

  List<Widget>? _makeOpening(BuildContext context) {
    if(_church.longinfo == null) {
      return null;
    }
    return <Widget>[
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Flexible(
                child: Text(
                 "Öffnungszeiten",
                  textScaleFactor: 1.5,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
            )
          ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              child: Html(data: _church.longinfo!),
          ),
        ],
      ),
    ];
  }

  List<Widget>? _makeSpecialInfo(BuildContext context) {
    List<Widget> res = <Widget>[];
    if(_church.stamp != null) {
      res += _makeSection(context, <Widget>[
        Row(
          children: const [
            Flexible(
                child: Text(
                  "Stempel",
                  textScaleFactor: 1.2,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Html(data: _church.stamp!),
            ),
          ],
        ),
      ]);
    }
    if(_church.spiritual != null) {
      res += _makeSection(context, <Widget>[
        Row(
          children: const [
            Flexible(
              child: Text(
                "Spiritueller Impuls",
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Html(data: _church.spiritual!),
            ),
          ],
        ),
      ]);
    }
    if(_church.reformation != null) {
      res += _makeSection(context,<Widget>[
        Row(
          children: const [
            Flexible(
              child: Text(
                "Zur Reformation",
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Html(data: _church.reformation!),
            ),
          ],
        ),
      ]);
    }
    return res.isNotEmpty ? res : null;
  }

  Widget _showPictures(BuildContext context) {
    final PageController controller = PageController();
    return
      Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Bilder"),
        ),
        body: FutureBuilder(
            future: DatabaseHelper().loadChurchImages(_church.id),
            builder: (BuildContext context, AsyncSnapshot<List<Map<String,Object?>>> s) {
              switch(s.connectionState) {
                case ConnectionState.waiting:
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                default:
                  if(s.hasError) {
                    return const Text("Bilder konnten nicht geladen werden.");
                  } else {
                    return PageView.builder(
                        controller: controller,
                        itemCount: s.data!.length,
                        itemBuilder: (BuildContext context, int idx) {
                          return Column(
                              children: <Widget> [
                                Container(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column( children: <Widget>[
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                              child: Text(
                                                _church.place,
                                                textScaleFactor: 1.8,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              )
                                          )
                                        ]
                                    ),
                                    const SizedBox(height: 10.0,),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                              child: Text(
                                                _church.name,
                                                textScaleFactor: 1.2,
                                                textAlign: TextAlign.center,
                                              )
                                          )
                                        ]
                                    ),
                                    const SizedBox(height: 20.0,),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                              child: Text(
                                                "${s.data![idx]['title']}",
                                                textScaleFactor: 1.2,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              )
                                          )
                                        ]
                                    ),
                                  ]
                                  ),
                                ),
                                const SizedBox(height: 40.0,),
                                Expanded(
                                  child: CachedNetworkImage(
                                    imageUrl: "https://www.kirche-mv.de/appfolder/${s.data![idx]['filename']}",
                                    placeholder: (_,__) => Image.asset("assets/${s.data![idx]['filename']}"),
                                  ),
                                ),
                              ]
                          );
                        });
                  }
              }
            }
        )
      );
  }

  Widget _makeUtilityButtons(BuildContext context) {
    List<Widget> children = <Widget>[
      Column(
      children: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => _showPictures(context)));
          },
          icon: const Icon(
              Icons.photo,
              size: 30.0
          ),
        ),
        const Text("Bilder")
      ],
    ),
    ];
    if(_church.sketchimage != null) {
      children.add(
        Column(
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    appBar: AppBar(
                      leading: const BackButton(),
                      title: const Text("Grundriss"),
                    ),
                    body: SizedBox.expand(
                      child: InteractiveViewer(
                        panEnabled: false,
                        minScale: 1.0,
                        maxScale: 2.5,
                        child: Image.asset(
                          "assets/${_church.sketchimage}",
                          fit: BoxFit.contain,
                        )
                      ),
                    ),
                  );
                }));
              },
              icon: const Icon(
                  Icons.dashboard_outlined,
                  size: 30.0
              ),
            ),
            const Text("Grundriss")
          ],
        ),
      );
    }
    children.add(
      Column(
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    leading: const BackButton(),
                    title: const Text("Information"),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                  child: Text(
                                    _church.place,
                                    textScaleFactor: 1.8,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )
                              )
                            ]
                        ),
                        const SizedBox(height: 10.0,),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                  child: Text(
                                    _church.name,
                                    textScaleFactor: 1.2,
                                    textAlign: TextAlign.center,
                                  )
                              )
                            ]
                        ),
                        const SizedBox(height: 10.0,),
                        Html(data: _church.history),
                      ],
                    ),
                  ),
                );
              }));
            },
            icon: const Icon(
                Icons.info_outline,
                size: 30.0
            ),
          ),
          const Text("Information")
        ],
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children
    );
  }

  List<Widget> _makeSection(BuildContext context, List<Widget> els) {
    return <Widget>[const SizedBox(height: 10.0)]
        + els
        + <Widget>[const SizedBox(height: 10.0),const Divider(thickness: 1.0,)];
  }

  @override
  Widget build(BuildContext context) {

    _visits = Provider.of<ChurchProvider>(context, listen: true).getVisits(widget.churchId);
    _church = Provider.of<ChurchProvider>(context, listen: true).getChurch(widget.churchId);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        leading: const BackButton(
        ),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                  appBar: AppBar(
                    leading: const BackButton(),
                    title: Text(_church.place),
                  ),
                  body: MapPage(churches: [_church], interactive: false)
              );
            }));
          },
              icon: const Icon(Icons.map, semanticLabel: "Kirche auf Karte ansehen.",))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        child: SingleChildScrollView(
          child: Column(
            children: (BuildContext context) {
              List<Widget> res = <Widget>[];
              res += _makeTitle(context);
              res.add(const SizedBox(height: 20.0));
              res.add(_makeUtilityButtons(context));
              res.add(const SizedBox(height: 20.0));
              final info = _makeInfo(context);
              final opening = _makeOpening(context);
              if(info != null) {
                res += _makeSection(context, info);
              }
              if(opening != null) {
                res += _makeSection(context, opening);
              }
              final specialInfo = _makeSpecialInfo(context);
              if(specialInfo != null) {
                res += specialInfo;
              }
              res += _makeChurchData(context);
              res.add(const SizedBox(height: 30.0,));
              res += _makeVisitsList(context);
              return res;
            }(context),
          ),
        ),
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