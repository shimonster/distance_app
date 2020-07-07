import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class TrackDistanceFloatingActionButton extends StatefulWidget {
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
  _TrackDistanceFloatingActionButtonState createState() =>
      _TrackDistanceFloatingActionButtonState();
}

class _TrackDistanceFloatingActionButtonState
    extends State<TrackDistanceFloatingActionButton>
    with TickerProviderStateMixin {
  Animation<double> _latAnimation;
  Animation<double> _lngAnimation;
  AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
    );
  }

  void _setAnims() {
    final bool wasNull = _latAnimation == null;
    _animController.duration = Duration(
      milliseconds: Distance()
          .as(LengthUnit.Meter, widget._mapController.center,
              widget._points.last['LatLng'])
          .round(),
    );
    if (widget._mapController.ready) {
      _latAnimation = Tween<double>(
        begin: widget._mapController.center.latitude,
        end: widget._points.last['LatLng'].latitude,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeIn,
        ),
      );
      _lngAnimation = Tween<double>(
        begin: widget._mapController.center.longitude,
        end: widget._points.last['LatLng'].longitude,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOut,
        ),
      );
      if (wasNull) {
        print('added listener');
        _latAnimation.addListener(() {
          widget._mapController.move(
              LatLng(_latAnimation.value, _lngAnimation.value),
              widget._mapController.zoom);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 120, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'Back button',
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
            heroTag: 'Go to location button',
            child: Icon(Icons.my_location),
            onPressed: () {
              _setAnims();
              _animController.reset();
              _animController.forward();
              //_isAtLastPoint = true;
            },
          ),
        ],
      ),
    );
  }
}
