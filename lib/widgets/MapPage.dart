import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:kirche/model/church.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'DetailPage.dart';

class ChurchMarker extends Marker {
  ChurchMarker({required this.idx, required super.point}) :
  super(
        builder: (ctx) => const Icon(
          size: 50.0,
          Icons.location_on,
          color: Colors.redAccent,
          semanticLabel: "Kirchenstandort",
        ),
      );

  final int idx;
}

class MapPage extends StatefulWidget {
  MapPage({super.key, required this.churches, this.interactive = true, this.location});

  final List<Church> churches;
  final bool interactive;
  LatLng? location;


  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  LatLng center = LatLng(53.9653418, 12.8228524);
  final maxLatLng = LatLng(58.3498, -10.2603);
  final _popupController = PopupController();
  final _popupState = PopupState();
  bool _location = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> _createLayers() {
    List<Widget> res = [
      TileLayer(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: const ['a', 'b', 'c'],
      ),
      MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          rotate: true,
          maxClusterRadius: 100,
          size: const Size(40, 40),
          anchor: AnchorPos.align(AnchorAlign.center),
          fitBoundsOptions: const FitBoundsOptions(
            padding: EdgeInsets.all(50),
            maxZoom: 15,
          ),
          markers: widget.churches.asMap().entries.map((e) => ChurchMarker (
            point: LatLng(e.value.lat, e.value.lon),
            idx: e.key,
          )).toList(),
          popupOptions: widget.interactive ? PopupOptions(
              popupState: _popupState,
              popupSnap: PopupSnap.markerTop,
              popupController: _popupController,
              popupBuilder: (_, m) => Container(
                width: 200,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  boxShadow: [BoxShadow(blurRadius: 3.0,)],
                ),
                child: m is ChurchMarker ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => DetailPage(churchId: widget.churches[m.idx].id)
                        )
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image(image: AssetImage('assets/${widget.churches[m.idx].thumbnail}')),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.churches[m.idx].place,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.churches[m.idx].name,
                          )
                        ],
                      )
                    ],
                  ),
                ) : null,
              )
          ) : null,
          builder: (context, markers) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue),
              child: Center(
                child: Text(
                  markers.length.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    ];
    if(_location) {
      res.add(CurrentLocationLayer(
      ));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight!,
        child: FlutterMap(
            options: MapOptions(
              center: center,
              maxBounds: LatLngBounds(LatLng(54.737220, 6.825914), LatLng(49.751138, 15.279419)),
              zoom: 7,
              maxZoom: 15,
              keepAlive: true,
              onTap: (_,__) => _popupController.hideAllPopups(),
            ),
            nonRotatedChildren: [
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () async {
                    LocationPermission perm = await Geolocator.checkPermission();
                    bool locOn = await Geolocator.isLocationServiceEnabled();
                    if(perm == LocationPermission.denied) {
                      perm = await Geolocator.requestPermission();
                    }
                    switch(perm) {
                      case LocationPermission.whileInUse:
                      case LocationPermission.always:
                        setState(() {
                          if(!_location) {
                            _location = true;
                          }
                        });
                        break;
                      default:
                        break;
                    }
                  },
                  child: Icon(_location ? Icons.my_location : Icons.location_searching),
                ),
              ),
            ],
            children: _createLayers()
        ),
    );
  }
}