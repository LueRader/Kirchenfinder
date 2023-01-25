import 'package:flutter/material.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/widgets/DetailPage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.churches});

  final List<Church> churches;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final center = LatLng(53.9653418, 12.8228524);
  final maxLatLng = LatLng(58.3498, -10.2603);
  final _popupController = PopupController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: 7,
        maxZoom: 15,
        keepAlive: true,
        onTap: (_,__) => _popupController.hideAllPopups(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            rotate: true,
            maxClusterRadius: 45,
            size: const Size(40, 40),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: const FitBoundsOptions(
              padding: EdgeInsets.all(50),
              maxZoom: 15,
            ),
            markers: widget.churches.map((e) => Marker (
                point: LatLng(e.lat, e.lon),
                builder: (ctx) => const Icon(
                  size: 50.0,
                  Icons.location_on,
                  color: Colors.redAccent,
                  semanticLabel: "Kirchenstandort",
                )
            )).toList(),
            popupOptions: PopupOptions(
              popupState: PopupState(),
              popupSnap: PopupSnap.markerTop,
              popupController: _popupController,
              popupAnimation: const PopupAnimation.fade(),
              popupBuilder: (_, m) => Container(
                width: 200,
                height: 100,
                color: Colors.white,
                child: GestureDetector(
                  child: const Text('A popup'),
                ),
              )
            ),
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
      ],
    );
  }
}