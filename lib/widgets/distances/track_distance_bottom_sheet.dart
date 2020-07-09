import 'package:flutter/cupertino.dart';
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
  final name = TextEditingController();
  final nameFocus = FocusNode();
  double dist;

  @override
  void initState() {
    super.initState();
    dist = Provider.of<Distances>(context, listen: false)
        .computeTotalDist(widget._points);
  }

  Widget _buildModalContent() {
    return StatefulBuilder(
      builder: (ctx, setModalState) {
        return Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: name,
                    focusNode: nameFocus,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    onTap: () {
                      FocusScope.of(ctx).requestFocus(nameFocus);
                    },
                    textAlignVertical: TextAlignVertical.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    child: DropdownButton<String>(
                      value: category,
                      onTap: () {
                        nameFocus.unfocus();
                      },
                      hint: Text('Category'),
                      underline: Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey,
                      ),
                      onChanged: (String cat) {
                        setModalState(() {
                          category = cat;
                        });
                        print('new drop down value: $cat');
                      },
                      isExpanded: true,
                      items: Provider.of<Categories>(ctx, listen: false)
                          .categories
                          .map(
                            (e) => DropdownMenuItem<String>(
                              child: Text(e),
                              value: e,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Finish'),
                    onPressed: () async {
                      final distances =
                          Provider.of<Distances>(ctx, listen: false);
                      await distances.addDistance(
                          name.text,
                          widget._points.first['time'],
                          distances.preferredUnit,
                          category,
                          widget._points,
                          dist);
                      Navigator.of(ctx).pop();
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                      name.clear();
                    },
                  ),
                  if (MediaQuery.of(ctx).viewInsets.bottom > 0 &&
                      nameFocus.hasFocus)
                    Expanded(
                      child: Container(),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitDistance() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _buildModalContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    dist = Provider.of<Distances>(context, listen: false)
        .computeTotalDist(widget._points);
    print('bottomsheet build was run');

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
                    'Current Distance: ${dist.toStringAsFixed(3)}',
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
