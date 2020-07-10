import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';

import '../../providers/distances.dart' as d;
import '../../screens/distances/distance_details_screen.dart';

class DistanceDisplayWidget extends StatelessWidget {
  DistanceDisplayWidget(this.distId, key) : super(key: key);

  final String distId;
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final distances = Provider.of<d.Distances>(context);
    final dist =
        distances.distances.firstWhere((element) => element.id == distId);

    Map<String, dynamic> getZoomCenter() {
      LatLng mostLat;
      LatLng lestLat;
      LatLng mostLng;
      LatLng lestLng;

      dist.markers.forEach((m) {
        final ll = m['LatLng'];
        if (mostLat == null) {
          mostLat = ll;
          lestLat = ll;
          mostLng = ll;
          lestLng = ll;
        } else if (ll.latitude > mostLat.latitude) {
          mostLat = ll;
        } else if (ll.latitude < lestLat.latitude) {
          lestLat = ll;
        } else if (ll.longitude > mostLng.longitude) {
          mostLng = ll;
        } else if (ll.longitude < lestLng.longitude) {
          lestLng = ll;
        }
      });

      final latDist = Distance().as(LengthUnit.Meter, lestLat, mostLat);
      final lngDist = Distance().as(LengthUnit.Meter, lestLng, mostLng);

      final zoom = sqrt(max(latDist, lngDist)) * 0.23 - 0.1;

      final center = LatLng(
          lestLat.latitude + ((mostLat.latitude - lestLat.latitude) / 2),
          lestLng.longitude + ((mostLng.longitude - lestLng.longitude) / 2));

      return {'zoom': 19 - zoom, 'center': center};
    }

    final zoomCenter = getZoomCenter();

    _mapController.onReady.then((value) =>
        _mapController.move(zoomCenter['center'], _mapController.zoom));
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => DistanceDetailsScreen(dist)));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 5, color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: GridTile(
            child: Stack(
              children: <Widget>[
                Hero(
                  tag: dist.id,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: zoomCenter['center'],
                      interactive: false,
                      zoom: zoomCenter['zoom'],
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(
                        markers: dist.markers.map<Marker>((e) {
                          final int calcAlt =
                              (sqrt(max(e['alt'] + 1300, 0)) * 1.84).round();
                          return Marker(
                            point: e['LatLng'],
                            width: 9,
                            builder: (ctx) => CircleAvatar(
                              backgroundColor: e['alt'] <= 0
                                  ? Color.fromRGBO(0, 255, 0, 1)
                                  : e['alt'] > 30000
                                      ? Colors.white
                                      : Color.fromRGBO(
                                          min((calcAlt).round(), 255),
                                          max((255 - calcAlt).round(),
                                              -510 + calcAlt * 2),
                                          min((calcAlt * 2).round(),
                                              380 - calcAlt),
                                          1),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black.withOpacity(0.8),
                  child: Text(
                    dist.name,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black54,
              title: Center(
                child: Text(
                  '${dist.distance.toStringAsFixed(3)} ${distances.preferredUnit}',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
