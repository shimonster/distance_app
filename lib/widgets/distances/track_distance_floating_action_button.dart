import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class TrackDistanceFloatingActionButton extends StatelessWidget {
  const TrackDistanceFloatingActionButton({
    Key key,
    @required MapController mapController,
    @required List<Map<String, dynamic>> points,
  })  : _mapController = mapController,
        _points = points,
        super(key: key);

  final MapController _mapController;
  final List<Map<String, dynamic>> _points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 120, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Are you sure'),
                  content:
                      Text('If you go back, all you progress will be lost.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          FloatingActionButton(
            child: Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_points.last['LatLng'], _mapController.zoom);
              //_isAtLastPoint = true;
            },
          ),
        ],
      ),
    );
  }
}
