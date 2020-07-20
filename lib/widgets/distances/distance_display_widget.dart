import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';

import 'package:distanceapp/main.dart';
import 'package:distanceapp/providers/distances.dart' as d;
import 'package:distanceapp/screens/distances/distance_details_screen.dart';
import 'package:distanceapp/helpers/config.dart';

class DistanceDisplayWidget extends StatelessWidget {
  DistanceDisplayWidget(this.distId, key) : super(key: key);

  final String distId;

  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['distanceDisplayWidget'];

    final distances = Provider.of<d.Distances>(context, listen: false);
    final dist =
        distances.distances.firstWhere((element) => element.id == distId);

    final zoomCenter = Config().getPathInfo(dist, 250);

    _mapController.onReady.then((value) =>
        _mapController.move(zoomCenter['center'], _mapController.zoom));

    final radius = BorderRadius.circular(style['radius']);
    return Card(
      margin: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      elevation: style['elevation'],
      shadowColor: Theme.of(context).accentColor,
      child: ClipRRect(
        borderRadius: radius,
        child: InkWell(
          splashColor: Colors.white,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => DistanceDetailsScreen(dist),
              ),
            );
          },
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
                        markers: dist.markers
                            .map<Marker>((e) => Config().buildMarker(e))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(style['namePadding']),
                  color:
                      Colors.black.withOpacity(style['nameContainerOpacity']),
                  child: Text(
                    dist.name,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            footer: GridTileBar(
              backgroundColor:
                  Colors.black.withOpacity(style['distanceContainerOpacity']),
              title: Center(
                child: Consumer<d.Distances>(
                  builder: (ctx, dists, _) {
                    return Text(
                      '${(dists.computeTotalDist(dist.markers) / (dists.preferredUnit == 'Miles' ? 1609.344 : 1000)).toStringAsFixed(style['distanceAccuracy'])} ${dists.preferredUnit}',
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
