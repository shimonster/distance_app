import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

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
                              max((255 - calcAlt).round(), -510 + calcAlt * 2),
                              min((calcAlt * 2).round(), 380 - calcAlt),
                              1),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      footer: GridTileBar(
        title: Text(dist.name),
      ),
    );
  }
}
