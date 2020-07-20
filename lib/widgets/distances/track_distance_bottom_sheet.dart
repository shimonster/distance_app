import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:distanceapp/providers/distances.dart';
import 'package:distanceapp/widget/distances/track_distance_modal_bottom_sheet.dart'
import 'package:distanceapp/main.dart';

class TrackDistanceBottomSheet extends StatefulWidget {
  const TrackDistanceBottomSheet({
    Key key,
    @required List<Map<String, dynamic>> points,
  })  : _points = points,
        super(key: key);

  final List<Map<String, dynamic>> _points;

  @override
  _TrackDistanceBottomSheetState createState() =>
      _TrackDistanceBottomSheetState();
}

class _TrackDistanceBottomSheetState extends State<TrackDistanceBottomSheet> {
  double dist;

  @override
  void initState() {
    super.initState();
    dist = Provider.of<Distances>(context, listen: false)
        .computeTotalDist(widget._points);
  }

  Future<void> _submitDistance() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => TrackDistanceModalBottomSheet(widget._points, dist),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['trackDistanceBottomSheet'];

    final distances = Provider.of<Distances>(context, listen: false);
    dist = distances.computeTotalDist(widget._points) /
        (distances.preferredUnit == 'Miles' ? 1609.344 : 1000);

    return Container(
      width: double.infinity,
      height: style['height'],
      color: Theme.of(context).primaryColorLight,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'Current Distance: ${dist.toStringAsFixed(mainStyle['appStyle']['distanceDisplayWidget']['distanceAccuracy'])} ${distances.preferredUnit}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: style['font'],
                    ),
                  ),
                  Text(
                    'Points: ${widget._points.length}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: style['font'],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: RaisedButton.icon(
              onPressed: () {
                _submitDistance();
              },
              icon: Icon(Icons.check),
              label: Text(
                'Finish',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
