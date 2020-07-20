import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:distanceapp/providers/distances.dart';
import 'package:distanceapp/providers/categories.dart';
import 'package:distanceapp/main.dart';

class TrackDistanceModalBottomSheet extends StatefulWidget {
  TrackDistanceModalBottomSheet(this._points, this.dist);

  final List<Map<String, dynamic>> _points;
  final double dist;

  @override
  _TrackDistanceModalBottomSheetState createState() =>
      _TrackDistanceModalBottomSheetState();
}

class _TrackDistanceModalBottomSheetState
    extends State<TrackDistanceModalBottomSheet> {
  bool isLoading = false;
  String category;
  final name = TextEditingController();
  final nameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['trackDistanceModalBottomSheet'];

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(style['padding']),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * style['maxHeight'],
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
                  FocusScope.of(context).requestFocus(nameFocus);
                },
                textAlignVertical: TextAlignVertical.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: style['dropDownButtonHeight'],
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
                    setState(() {
                      category = cat;
                    });
                  },
                  isExpanded: true,
                  items: Provider.of<Categories>(context, listen: false)
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
                        setState(() {
                          isLoading = true;
                        });
                        final distances =
                            Provider.of<Distances>(context, listen: false);
                        print('start adding');
                        await distances.addDistance(
                            name.text,
                            widget._points.first['time'],
                            distances.preferredUnit,
                            category,
                            widget._points,
                            widget.dist);
                        setState(() {
                          isLoading = true;
                        });
                        name.text = '';
                        Navigator.of(context).pop();
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
              if (MediaQuery.of(context).viewInsets.bottom > 0 &&
                  nameFocus.hasFocus)
                Expanded(
                  child: Container(),
                ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
