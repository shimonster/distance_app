import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:distanceapp/providers/distances.dart' as d;
import 'package:distanceapp/main.dart';
import 'package:distanceapp/helpers/config.dart';

class DistanceDetailsScreen extends StatelessWidget {
  DistanceDetailsScreen(this.dist);

  final d.Distance dist;

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['distanceDetailsScreen'];

    final Duration distTime =
        dist.markers.last['time'].difference(dist.markers.first['time']);
    final pInfo = Config().getPathInfo(
        dist, MediaQuery.of(context).size.height * style['mapHeight']);
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
                        markers: dist.markers
                            .map((e) => Config().buildMarker(e))
                            .toList(),
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
