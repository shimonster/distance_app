import 'dart:ui';
import 'dart:isolate';
import 'dart:math';

import 'package:background_locator/location_settings.dart' as ls;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';

import '../../providers/distances.dart' as ds;
import '../../widgets/distances/track_distance_floating_action_button.dart';

class AddDistanceTrackScreen extends StatefulWidget {
  static const routeName = '/add_distance_track_screen';

  @override
  _AddDistanceTrackScreenState createState() => _AddDistanceTrackScreenState();
}

class _AddDistanceTrackScreenState extends State<AddDistanceTrackScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _points = [];
  bool _isAtLastPoint = true;
  bool _isLoading = false;
  bool _hasDisposed = false;
  final MapController _mapController = MapController();
  final Distance distance = Distance();
  static const _isolateName = 'LocationIsolate';
  ReceivePort port = ReceivePort();
  Stream _locationStream;

  static const _distanceFilter = 5.0;
  static const _interval = 3;
  static const _initialZoom = 18.0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('paused');
      _startBackgroundLocation();
    } else {
      print('other');
      IsolateNameServer.removePortNameMapping(_isolateName);
      BackgroundLocator.unRegisterLocationUpdate();
    }
  }

  @override
  void dispose() {
    _hasDisposed = true;
    IsolateNameServer.removePortNameMapping(_isolateName);
    BackgroundLocator.unRegisterLocationUpdate();
    _locationStream = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _mapController.onReady.then((value) =>
        _isAtLastPoint = _mapController.center == _points.last['LatLng']);
    _locationStream = Location().onLocationChanged
      ..listen(
        (LocationData event) => _hasDisposed
            ? null
            : _addPoint(
                {
                  'LatLng': LatLng(event.latitude, event.longitude),
                  'alt': 100, //event.altitude
                },
              ),
      );
    Location().requestPermission();
    Location().changeSettings(
        interval: _interval * 1000,
        distanceFilter: _distanceFilter,
        accuracy: LocationAccuracy.high);
    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    port.listen((dynamic data) {
      _addPoint(data);
    });
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  static void backgroundLocationCallback(LocationDto loc) {
    final SendPort sent = IsolateNameServer.lookupPortByName(_isolateName);
    sent?.send(loc);
  }

  void _startBackgroundLocation() {
    BackgroundLocator.registerLocationUpdate(
      backgroundLocationCallback,
      settings: ls.LocationSettings(
        distanceFilter: _distanceFilter,
        interval: _interval,
      ),
    );
  }

  void _addPoint(Map<String, dynamic> loc) {
    print(_points.length);
    if (_points.isNotEmpty) {
      if (_points.last != loc) {
        print([loc, _points.last]);
        _points.add(loc);
      }
    } else {
      print('pity add');
      _points.add(loc);
    }
    if (_isAtLastPoint) {
      if (_mapController.ready) {
        _mapController.move(_points.last['LatLng'], _mapController.zoom);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _locationStream,
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
                              center: _points.last['LatLng'],
                              zoom: _initialZoom,
                              onPositionChanged: (pos, _) {
                                if (_points.isNotEmpty) {
                                  if (pos.center != _points.last['LatLng']) {
                                    _isAtLastPoint = false;
                                  }
                                }
                              },
                            ),
                            layers: [
                              new TileLayerOptions(
                                  urlTemplate:
                                      "http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c']),
                              MarkerLayerOptions(
//                                  markers: _points.expand((element) {
//                                final List<Marker> markers = [];
//                                for (var i = 0; i < 5000; i++) {
//                                  markers.add(_buildMarker({
//                                    'LatLng': LatLng(i / 1000, 0),
//                                    'alt': (i - 150) * 10
//                                  }));
//                                }
//                                return markers;
//                              }).toList()
                                markers: _points
                                    .map((e) => _buildMarker(e))
                                    .toList(),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: TrackDistanceFloatingActionButton(
          mapController: _mapController, points: _points),
      bottomSheet: Container(
        width: double.infinity,
        height: 70,
        color: Theme.of(context).primaryColorLight,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Current Distance: ${Provider.of<ds.Distances>(context, listen: false).computeTotalDist(_points)}',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'Points: ${_points.length}',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Finish',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
