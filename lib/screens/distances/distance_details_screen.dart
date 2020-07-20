import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:distanceapp/providers/distances.dart' as d;
import 'package:distanceapp/main.dart';

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
    final int calcAlt = (sqrt(max(point['alt'], 0)) * 2.5).round() + 10;
    return Marker(
      point: point['LatLng'],
      width: 9,
      builder: (ctx) => CircleAvatar(
        backgroundColor: point['alt'] <= 0
            ? Color.fromRGBO(0, 255, 0, 1)
            : point['alt'] > 17000
                ? Colors.white
                : Color.fromRGBO(
                    min((calcAlt).round(), 255),
                    max((255 - calcAlt).round(),
                        (-510 + calcAlt * 2.2).round()),
                    min((calcAlt * 2).round(), 380 - calcAlt),
                    1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['distanceDetailsScreen'];

    final Duration distTime =
        dist.markers.last['time'].difference(dist.markers.first['time']);
    final pInfo = getPathInfo();
    final distances = Provider.of<d.Distances>(context, listen: false);

    Widget _buildInfoText(bool isHeading, String text) {
      return Padding(
        padding: EdgeInsets.only(
            left: isHeading
                ? style['headingLeftPadding']
                : style['normalLeftPadding'],
            top: style['topPadding']),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: isHeading ? FontWeight.bold : null,
              fontSize: style['font']),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dist.name),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * style['mapHeight'],
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
                  right: style['nameRight'],
                  bottom:
                      MediaQuery.of(context).size.height * style['nameBottom'],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(style['nameBorderRadius']),
                      ),
                      color: Colors.black54,
                    ),
                    width:
                        MediaQuery.of(context).size.width * style['nameWidth'],
                    padding: EdgeInsets.all(style['namePadding']),
                    child: Text(
                      dist.name,
                      style: TextStyle(
                          fontSize: style['nameFont'], color: Colors.white),
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
                    Theme.of(context)
                        .primaryColor
                        .withOpacity(style['primaryOpacity']),
                    Theme.of(context)
                        .accentColor
                        .withOpacity(style['accentOpacity']),
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
                        'Average Speed: ${((distances.computeTotalDist(dist.markers) / (distances.preferredUnit == 'Miles' ? 1609.344 : 1000)) / (distTime.inSeconds / 3600)).toStringAsFixed(style['speedAccuracy'])}  ${distances.preferredUnit == 'Miles' ? 'mph' : 'kph'}'),
                    Divider(),
                    _buildInfoText(true, 'Path Info'),
                    _buildInfoText(false,
                        'Distance: ${(distances.computeTotalDist(dist.markers) / (distances.preferredUnit == 'Miles' ? 1609.344 : 1000)).toStringAsFixed(mainStyle['appStyle']['distanceDisplayWidget']['distanceAccuracy'])} ${distances.preferredUnit == 'Miles' ? 'Miles' : 'Kilometers'}'),
                    _buildInfoText(false,
                        'Lowest Altitude: ${pInfo['minAlt'].toStringAsFixed(style['altitudeAccuracy'])}'),
                    _buildInfoText(false,
                        'Highest Altitude: ${pInfo['minAlt'].toStringAsFixed(style['altitudeAccuracy'])}'),
                    _buildInfoText(false,
                        'Change in Altitude: ${(pInfo['minAlt'] - pInfo['minAlt']).toStringAsFixed(style['altitudeAccuracy'])}'),
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
