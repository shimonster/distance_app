import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class DistanceDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: FlutterMap(
        options: MapOptions(interactive: false, center: LatLng(0, 0)),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://api.tomtom.com/map/1/tile/basic/main/"
                "{z}/{x}/{y}.png?key={apiKey}",
//            wmsOptions: WMSTileLayerOptions(
//              styles: ['night'],
//            ),
            additionalOptions: {
              'apiKey': 'kNNg2Al5OGZUWcCpC0MeaoCQeCCeNzrl',
            },
          ),
        ],
      ),
      footer: GridTileBar(
        title: Text('Add Distance'),
      ),
    );
    ;
  }
}
