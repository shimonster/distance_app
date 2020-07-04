import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/distances.dart' as ds;

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

  @override
  void initState() {
    Location().requestPermission();
    setState(() {
      Location().getLocation().then((value) {
        setState(() {
          _points.add({
            'LatLng': LatLng(value.latitude, value.longitude),
            'alt': value.altitude,
          });
        });
      });
    });
    Location().changeSettings(
        interval: 3000, distanceFilter: 10, accuracy: LocationAccuracy.high);
    super.initState();
  }

  Marker _buildMarker(LatLng point) {
    return Marker(
      point: point,
      width: 9,
      builder: (ctx) => CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: Location().onLocationChanged
        ..listen((event) {
          print(event.accuracy);
          final ptLoc = {
            'LatLng': LatLng(event.latitude, event.longitude),
            'alt': event.altitude
          };
          if (_points.isNotEmpty) {
            if (_points.last != ptLoc) {
              _points.add(ptLoc);
            }
          } else {
            _points.add(ptLoc);
          }
          //if (_isAtLastPoint) {
          _mapController.move(_points.last['LatLng'], 15);
          //}
        }),
      builder: (ctx, snapshot) => _points.isEmpty
          ? Center(
              child: Text('Loding...'),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: snapshot.data == null
                                ? null
                                : LatLng(snapshot.data.latitude,
                                    snapshot.data.longitude),
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
                              markers: _points
                                  .map((e) => _buildMarker(e['LatLng']))
                                  .toList(),
                            ),
                          ],
                        ),
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Theme.of(context).primaryColorLight,
                  child: Center(
                    child: Text(
                      'Current Distance: ${Provider.of<ds.Distances>(context, listen: false).computeTotalDist(_points)}',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              ],
            ),
    ));
  }
}
