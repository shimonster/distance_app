import 'dart:ui';
import 'dart:isolate';

import 'package:background_locator/location_settings.dart' as ls;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:provider/provider.dart';

import 'package:distanceapp/helpers/config.dart';
import 'package:distanceapp/widgets/distances/track_distance_floating_action_button.dart';
import 'package:distanceapp/widgets/distances/track_distance_bottom_sheet.dart';
import 'package:distanceapp/providers/distances.dart' as d;
import 'package:distanceapp/main.dart';

class AddDistanceTrackScreen extends StatefulWidget {
  static const routeName = '/add_distance_track_screen';

  @override
  _AddDistanceTrackScreenState createState() => _AddDistanceTrackScreenState();
}

class _AddDistanceTrackScreenState extends State<AddDistanceTrackScreen>
    with WidgetsBindingObserver {
  Map<dynamic, dynamic> mainStyle;
  Map<dynamic, dynamic> style;
  Map<dynamic, dynamic> function;

  List<Map<String, dynamic>> _points = [];
  bool _isAtLastPoint = true;
  bool _isLoading = false;
  bool _hasDisposed = false;
  final MapController _mapController = MapController();
  final Distance distance = Distance();
  ReceivePort port = ReceivePort();
  Stream _locationStream;

  static const _isolateName = 'LocationIsolate';

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
    mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    style = mainStyle['appStyle']['distanceDetailsScreen'];
    function = mainStyle['appFunctionality']['addTrackScreen'];
    Location().requestPermission();
    Location().changeSettings(
        interval: function['interval'] * 1000,
        distanceFilter: _points.isEmpty ? 0 : function['distanceFilter'],
        accuracy: LocationAccuracy.high);
    _mapController.onReady.then((value) =>
        _isAtLastPoint = _mapController.center == _points.last['LatLng']);
    _locationStream = Location().onLocationChanged
      ..listen(
        (LocationData event) => _hasDisposed
            ? null
            : _addPoint(
                {
                  'LatLng': LatLng(event.latitude, event.longitude),
                  'alt': event.altitude
                },
              ),
      );
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
        distanceFilter: function['distanceFilter'],
        interval: function['interval'],
      ),
    );
  }

  void _addPoint(Map<String, dynamic> loc) {
    final addMap = {
      ...loc,
      'time': DateTime.now(),
    };
    if (_mapController.ready) {
      if (_mapController.center == _points.last['LatLng']) {
        _mapController.move(_points.last['LatLng'], _mapController.zoom);
      }
    }
    if (_points.isNotEmpty) {
      final dist = d.Distances('').computeTotalDist([addMap, _points.last]);
      if (dist > function['distanceFilter']) {
        setState(() {
          _points.add(addMap);
        });
      }
    } else {
      setState(() {
        _points.add(addMap);
      });
    }
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
                              maxZoom: 19,
                              center: _points.last['LatLng'],
                              zoom: function['initialZoom'],
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
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayerOptions(
//                                  markers: _points.expand((element) {
//                                final List<Marker> markers = [];
//                                for (var i = 0; i < 5000; i++) {
//                                  markers.add(
//                                    _buildMarker({
//                                      'LatLng': LatLng(i / 1000, 0),
//                                      'alt': (i - 150) * 10
//                                    }),
//                                  );
//                                }
//                                return markers;
//                              }).toList()
                                markers: _points
                                    .map((e) => Config().buildMarker(e))
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
      bottomSheet: TrackDistanceBottomSheet(points: _points),
    );
  }
}
