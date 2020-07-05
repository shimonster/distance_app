import 'dart:ui';
import 'dart:isolate';

import 'package:background_locator/location_settings.dart' as ls;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';

import '../../providers/distances.dart' as ds;

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
    _locationStream = Location().onLocationChanged;
    _locationStream.listen((event) => _hasDisposed ? null : _addPoint(event));
    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    port.listen((dynamic data) {
      _addPoint(data);
    });
    initPlatformState();
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
        interval: _interval * 1000,
        distanceFilter: _distanceFilter,
        accuracy: LocationAccuracy.high);
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

  void _addPoint(dynamic loc) {
    print(_points.length);
    final ptLoc = {
      'LatLng': LatLng(loc.latitude, loc.longitude),
      'alt': loc.altitude
    };
    if (_points.isNotEmpty) {
      if (_points.last != ptLoc) {
        _points.add(ptLoc);
      }
    } else {
      _points.add(ptLoc);
    }
    if (_isAtLastPoint) {
      if (_mapController.ready) {
        _mapController.move(_points.last['LatLng'], _mapController.zoom);
      }
    }
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
                              center: LatLng(10, 10), //snapshot.data == null
//                                  ? null
//                                  : LatLng(snapshot.data.latitude,
//                                      snapshot.data.longitude),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: InkWell(
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
    );
  }
}
