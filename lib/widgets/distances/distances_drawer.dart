import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/categories.dart';
import '../../providers/distances.dart';

class DistanceDrawer extends StatefulWidget {
  DistanceDrawer(this.selectCategory, this.switchMode);

  final void Function(String cat) selectCategory;
  final void Function() switchMode;

  @override
  _DistanceDrawerState createState() => _DistanceDrawerState();
}

class _DistanceDrawerState extends State<DistanceDrawer> {
  var _isAdding = false;
  var _isProcessingAdd = false;
  final _name = TextEditingController();
  String preferredUnits;

  Future<void> addCat() async {
    setState(() {
      _isProcessingAdd = true;
    });
    await Provider.of<Categories>(context, listen: false)
        .addCategory(_name.text)
        .then((value) {
      setState(() {
        _isProcessingAdd = false;
        _isAdding = false;
      });
    });
  }

  @override
  void initState() {
    Provider.of<Distances>(context, listen: false)
        .getUnits()
        .then((value) => setState(() {
              preferredUnits =
                  Provider.of<Distances>(context, listen: false).preferredUnit;
            }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cats = Provider.of<Categories>(context, listen: false);
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Categories'),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  if (cats.uid == null) {
                    widget.switchMode();
                  }
                },
              ),
            ],
          ),
          StatefulBuilder(
            builder: (ctx, setButtonState) => DropdownButton<String>(
              value: preferredUnits,
              onChanged: (unit) {
                setButtonState(() {
                  preferredUnits = unit;
                  Provider.of<Distances>(context, listen: false).setUnit(unit);
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'Miles',
                  child: Text('Miles'),
                ),
                DropdownMenuItem<String>(
                  value: 'Kilometers',
                  child: Text('Kilometers'),
                ),
              ],
            ),
          ),
          Divider(),
          FutureBuilder(
            future: cats.sync(),
            builder: (context, sSnapshot) {
              return FutureBuilder(
                future: cats.getCategories(),
                builder: (ctx, snapshot) => snapshot.connectionState ==
                            ConnectionState.waiting ||
                        sSnapshot.connectionState == ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: cats.categories.length + 1,
                          itemBuilder: (ctx, i) => i != cats.categories.length
                              ? Container(
                                  margin: EdgeInsets.only(
                                      bottom: i == cats.categories.length - 1
                                          ? 0
                                          : 8,
                                      left: 8,
                                      right: 8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor:
                                        Theme.of(context).primaryColorLight,
                                    onTap: () {
                                      widget.selectCategory(cats.categories[i]);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(cats.categories[i]),
                                    ),
                                  ),
                                )
                              : !_isAdding
                                  ? FlatButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.create_new_folder),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text('Add Category')
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isAdding = true;
                                        });
                                      },
                                    )
                                  : Container(
                                      height: 40,
                                      margin: EdgeInsets.only(
                                          top: 8, left: 8, right: 8),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.5,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              width: 200,
                                              child: TextField(
                                                controller: _name,
                                                onChanged: (_) {
                                                  setState(() {});
                                                },
                                                onSubmitted: _name.text == ''
                                                    ? null
                                                    : (_) async {
                                                        await addCat();
                                                        _name.clear();
                                                      },
                                                autofocus: true,
                                                enableSuggestions: true,
                                                textAlignVertical:
                                                    TextAlignVertical.bottom,
                                                decoration: InputDecoration(
                                                  hintText: 'Name',
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: _isProcessingAdd
                                                ? FittedBox(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ) //Icon(Icons.cloud_upload)
                                                : Icon(
                                                    Icons.check_circle_outline,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                            onPressed: _name.text == ''
                                                ? null
                                                : () async {
                                                    await addCat();
                                                    _name.clear();
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
