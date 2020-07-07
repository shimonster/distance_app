import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/categories.dart';

class DistanceDrawer extends StatefulWidget {
  DistanceDrawer(this.selectCategory);

  final void Function(String cat) selectCategory;

  @override
  _DistanceDrawerState createState() => _DistanceDrawerState();
}

class _DistanceDrawerState extends State<DistanceDrawer> {
  var _isLoading = false;
  var _isAdding = false;
  var _isProcessingAdd = false;
  final _name = TextEditingController();

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Categories>(context, listen: false).getCategories();
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

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
  Widget build(BuildContext context) {
    final cats = Provider.of<Categories>(context);
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
                },
              ),
            ],
          ),
          if (_isLoading)
            Expanded(
              child: Center(child: Text('Loading...')),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: cats.categories.length + 1,
                itemBuilder: (ctx, i) => i != cats.categories.length
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: i == cats.categories.length - 1 ? 0 : 8,
                            left: 8,
                            right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          splashColor: Theme.of(context).primaryColorLight,
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                            margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 10),
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
                                          child: CircularProgressIndicator(),
                                        ) //Icon(Icons.cloud_upload)
                                      : Icon(Icons.check_circle_outline),
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
        ],
      ),
    );
  }
}
