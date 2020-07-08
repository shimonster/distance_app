import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../../providers/distances.dart' as d;

class DistanceDisplayWidget extends StatelessWidget {
  DistanceDisplayWidget(this.dist);

  final d.Distance dist;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: FlutterMap(
        options: MapOptions(
          center: dist.markers[(dist.markers.length / 2).round()]['LatLng'],
          interactive: false,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: dist.markers
                .map<Marker>((e) => Marker(
                      point: e['LatLng'],
                    ))
                .toList(),
          ),
        ],
      ),
      footer: GridTileBar(
        title: Text(dist.name),
      ),
    );
  }
}
