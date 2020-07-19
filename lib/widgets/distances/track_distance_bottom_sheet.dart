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
    bool isLoading = false;
    return StatefulBuilder(
      builder: (ctx, setModalState) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : RaisedButton(
                          child: Text('Finish'),
                          onPressed: () async {
                            setModalState(() {
                              isLoading = true;
                            });
                            final distances =
                                Provider.of<Distances>(ctx, listen: false);
                            print('start adding');
                            await distances.addDistance(
                                name.text,
                                widget._points.first['time'],
                                distances.preferredUnit,
                                category,
                                widget._points,
                                dist);
                            setModalState(() {
                              isLoading = true;
                            });
                            name.text = '';
                            Navigator.of(ctx).pop();
                            if (Navigator.of(ctx).canPop()) {
                              Navigator.of(ctx).pop();
                            }
                          },
                        ),
                  if (MediaQuery.of(ctx).viewInsets.bottom > 0 &&
                      nameFocus.hasFocus)
                    Expanded(
                      child: Container(),
                    ),
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
    final distances = Provider.of<Distances>(context, listen: false);
    dist = distances.computeTotalDist(widget._points) /
        (distances.preferredUnit == 'Miles' ? 1609.344 : 1000);

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
                    'Current Distance: ${dist.toStringAsFixed(3)} ${distances.preferredUnit}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Points: ${widget._points.length}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
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
