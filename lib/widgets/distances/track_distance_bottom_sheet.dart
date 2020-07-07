import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/distances.dart';
import '../../providers/categories.dart';

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
  String category;
  String name;

  @override
  Widget build(BuildContext context) {
    Future<void> _submitDistance() async {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButton(
                  selectedItemBuilder: (ctx) => [Text('cool')],
                  onChanged: (cat) {
                    category = cat;
                  },
                  isExpanded: true,
                  items: Provider.of<Categories>(context)
                      .categories
                      .map(
                        (e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
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
                    'Current Distance: ${Provider.of<Distances>(context, listen: false).computeTotalDist(widget._points)}',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Points: ${widget._points.length}',
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
              onTap: () {
                _submitDistance();
              },
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
    );
  }
}
