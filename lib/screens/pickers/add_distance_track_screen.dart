import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;

class AddDistanceTrackScreen extends StatefulWidget {
  static const routeName = '/add_distance_track_screen';

  @override
  _AddDistanceTrackScreenState createState() => _AddDistanceTrackScreenState();
}

class _AddDistanceTrackScreenState extends State<AddDistanceTrackScreen> {
  LocationData _location;
  List<Map<String, dynamic>> _points = [];
  bool _isAtLastPoint = true;
  LatLng _locLatLng;
  bool _isLoading = false;
  final MapController _mapController = MapController();
  final Distance distance = Distance();
  static const pointDensity = 200;
  static const minDistance = 0.5;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    getLocation();
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  Future<void> getLocation() async {
    _location = await Location().getLocation();
    print('getlocation was run');
    _locLatLng = _mapController
        .center /*LatLng(_location.latitude, _location.longitude)*/;
    if (_points.isNotEmpty) {
      if (_points.last['LatLng'] != _locLatLng) {
        if (_isAtLastPoint && _mapController.ready) {
          _mapController.move(_locLatLng, _mapController.zoom);
        }
        _points.add({'LatLng': _locLatLng, 'Alt': _location.altitude});
      }
    } else {
      _location = await Location().getLocation();
      print('getlocation was run');
      _locLatLng = _mapController
          .center /*LatLng(_location.latitude, _location.longitude)*/;
      _points.add({'LatLng': _locLatLng, 'Alt': _location.altitude});
    }
  }

  Marker _buildMarker(LatLng point) {
    return Marker(
      point: point,
      width: _mapController.zoom * 0.3,
      builder: (ctx) => CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream setUpStream() {
      return Stream.periodic(
          Duration(milliseconds: 400), (i) async => await getLocation());
    }

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder(
            stream: setUpStream(),
            builder: (ctx, snapshot) => Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _location == null
                            ? null
                            : LatLng(_location.latitude, _location.longitude),
                        zoom: 15,
                        onPositionChanged: (pos, _) {
                          if (_points.isNotEmpty) {
                            if (pos.center != _points.last['LatLng']) {
                              _isAtLastPoint = false;
                            }
                          }
                        },
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate:
                              "https://api.tomtom.com/map/1/tile/basic/main/"
                              "{z}/{x}/{y}.png?key={apiKey}",
                          additionalOptions: {
                            'apiKey': 'kNNg2Al5OGZUWcCpC0MeaoCQeCCeNzrl',
                          },
                        ),
                        MarkerLayerOptions(
                            markers: _points.expand((Map e) {
                          List<Marker> rtnPoints = [];
                          final ptIdx = _points.indexOf(e);
                          if (ptIdx != 0) {
                            final prevPoint = _points[ptIdx - 1]['LatLng'];
                            final num = Distance().as(
                                      LengthUnit.Meter,
                                      e['LatLng'],
                                      prevPoint,
                                    ) *
                                    _mapController.zoom /
                                    pointDensity +
                                1;
                            for (var i = 1; i <= num; i++) {
                              final point = mt.SphericalUtil.interpolate(
                                  mt.LatLng(e['LatLng'].latitude,
                                      e['LatLng'].longitude),
                                  mt.LatLng(
                                      prevPoint.latitude, prevPoint.longitude),
                                  i / num);
                              rtnPoints.add(_buildMarker(
                                  LatLng(point.latitude, point.longitude)));
                            }
                            //final Path pointsPath = Path.from(rtnPointss);
                            return rtnPoints;
                          } else {
                            return [_buildMarker(e['LatLng'])];
                          }
                        }).toList()),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
