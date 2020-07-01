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
  var _didInit = false;
  var _isLoading = false;
  var _isAdding = false;
  final _name = TextEditingController();

  @override
  void didChangeDependencies() {
    if (!_didInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Categories>(context, listen: false).getCategories();
      setState(() {
        _isLoading = false;
      });
    }
    _didInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cats = Provider.of<Categories>(context, listen: true);
    print('drawer build()');
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Categories'),
            automaticallyImplyLeading: false,
          ),
          if (_isLoading)
            Expanded(
              child: Center(child: Text('Loading...')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
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
                              Container(
                                width: 200,
                                child: TextField(
                                  controller: _name,
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  onSubmitted: _name.text == ''
                                      ? null
                                      : (_) {
                                          cats.addCategory(_name.text);
                                          _isAdding = false;
                                        },
                                  autofocus: true,
                                  enableSuggestions: true,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.check_circle_outline),
                                onPressed: _name.text == ''
                                    ? null
                                    : () {
                                        cats.addCategory(_name.text);
                                        _isAdding = false;
                                      },
                              ),
                            ],
                          ),
                        ),
            ),
        ],
      ),
    );
  }
}
