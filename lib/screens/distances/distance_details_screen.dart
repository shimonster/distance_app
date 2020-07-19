import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/distances.dart' as d;

class DistanceDetailsScreen extends StatelessWidget {
  DistanceDetailsScreen(this.dist);

  final d.Distance dist;

  Map<String, dynamic> getPathInfo() {
    LatLng mostLat;
    LatLng lestLat;
    LatLng mostLng;
    LatLng lestLng;
    double mostAlt;
    double lestAlt;

    dist.markers.forEach((m) {
      final ll = m['LatLng'];
      final a = m['alt'];
      if (mostLat == null) {
        mostLat = ll;
        lestLat = ll;
        mostLng = ll;
        lestLng = ll;
        mostAlt = a;
        lestAlt = a;
      } else if (ll.latitude > mostLat.latitude) {
        mostLat = ll;
      } else if (ll.latitude < lestLat.latitude) {
        lestLat = ll;
      } else if (ll.longitude > mostLng.longitude) {
        mostLng = ll;
      } else if (ll.longitude < lestLng.longitude) {
        lestLng = ll;
      }

      if (a > mostAlt) {
        mostAlt = a;
      } else if (a < lestAlt) {
        lestAlt = a;
      }
    });

    final latDist = Distance().as(LengthUnit.Meter, lestLat, mostLat);
    final lngDist = Distance().as(LengthUnit.Meter, lestLng, mostLng);

    final zoom = sqrt(max(latDist, lngDist)) * 0.23 - 0.1;

    final center = LatLng(
        lestLat.latitude + ((mostLat.latitude - lestLat.latitude) / 2),
        lestLng.longitude + ((mostLng.longitude - lestLng.longitude) / 2));

    return {
      'zoom': 19 - zoom,
      'center': center,
      'minAlt': lestAlt,
      'maxAlt': mostAlt
    };
  }

  Marker _buildMarker(Map<String, dynamic> point) {
    final int calcAlt = (sqrt(max(point['alt'] + 1300, 0)) * 1.84).round();
    return Marker(
      point: point['LatLng'],
      width: 9,
      builder: (ctx) => CircleAvatar(
        backgroundColor: point['alt'] <= 0
            ? Color.fromRGBO(0, 255, 0, 1)
            : point['alt'] > 30000
                ? Colors.white
                : Color.fromRGBO(
                    min((calcAlt).round(), 255),
                    max((255 - calcAlt).round(), -510 + calcAlt * 2),
                    min((calcAlt * 2).round(), 380 - calcAlt),
                    1),
      ),
    );
  }

  Widget _buildInfoText(bool isHeading, String text) {
    return Padding(
      padding: EdgeInsets.only(left: isHeading ? 15 : 40, top: 10),
      child: Text(
        text,
        style: style.copyWith(fontWeight: isHeading ? FontWeight.bold : null),
      ),
    );
  }

  final style = TextStyle(
    fontSize: 17,
  );

  @override
  Widget build(BuildContext context) {
    final Duration distTime =
        dist.markers.last['time'].difference(dist.markers.first['time']);
    final pInfo = getPathInfo();
    final distances = Provider.of<d.Distances>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(dist.name),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 1 / 3,
            child: Stack(
              children: <Widget>[
                Hero(
                  tag: dist.id,
                  child: FlutterMap(
                    options: MapOptions(
                      center: pInfo['center'],
                      interactive: false,
                      zoom: pInfo['zoom'],
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(
                        markers:
                            dist.markers.map((e) => _buildMarker(e)).toList(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 20,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    padding: EdgeInsets.all(20),
                    color: Colors.black54,
                    child: Text(
                      dist.name,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.5),
                    Theme.of(context).accentColor.withOpacity(0.5),
                  ],
                  end: Alignment.bottomRight,
                  begin: Alignment.topLeft,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildInfoText(true, 'General Info'),
                    _buildInfoText(false,
                        'Date: ${DateFormat('yMMMMd').format(dist.time)}'),
                    _buildInfoText(false,
                        'Distance Time: ${NumberFormat('00').format(distTime.inHours)}:${NumberFormat('00').format(distTime.inMinutes.remainder(60))}:${NumberFormat('00').format(distTime.inSeconds.remainder(60))}'),
                    _buildInfoText(false,
                        'Start: ${DateFormat('jms').format(dist.markers.first['time'])}'),
                    _buildInfoText(false,
                        'End: ${DateFormat('jms').format(dist.markers.last['time'])}'),
                    _buildInfoText(false,
                        'Average Speed: ${((distances.computeTotalDist(dist.markers) / (distances.preferredUnit == 'Miles' ? 1609.344 : 1000)) / (distTime.inSeconds / 3600)).toStringAsFixed(2)}  ${distances.preferredUnit == 'Miles' ? 'mph' : 'kph'}'),
                    Divider(),
                    _buildInfoText(true, 'Path Info'),
                    _buildInfoText(false,
                        'Distance: ${(distances.computeTotalDist(dist.markers) / (distances.preferredUnit == 'Miles' ? 1609.344 : 1000)).toStringAsFixed(2)} ${distances.preferredUnit == 'Miles' ? 'Miles' : 'Kilometers'}'),
                    _buildInfoText(false,
                        'Lowest Altitude: ${pInfo['minAlt'].toStringAsFixed(2)}'),
                    _buildInfoText(false,
                        'Highest Altitude: ${pInfo['minAlt'].toStringAsFixed(2)}'),
                    _buildInfoText(false,
                        'Change in Altitude: ${(pInfo['minAlt'] - pInfo['minAlt']).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
