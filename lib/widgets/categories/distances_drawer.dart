import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:distanceapp/providers/categories.dart';
import 'package:distanceapp/providers/distances.dart';
import 'package:distanceapp/main.dart';

class DistanceDrawer extends StatefulWidget {
  DistanceDrawer(
      this.selectCategory, this.switchMode, this.animationController);

  final void Function(String cat) selectCategory;
  final void Function() switchMode;
  final AnimationController animationController;

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
    super.initState();
    widget.animationController.reverse();
    Provider.of<Distances>(context, listen: false).getUnits().then(
          (value) => setState(() {
            preferredUnits =
                Provider.of<Distances>(context, listen: false).preferredUnit;
          }),
        );
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['distancesDrawer'];

    final cats = Provider.of<Categories>(context, listen: false);
    return Drawer(
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
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
              builder: (ctx, setButtonState) => Container(
                height: style['nameInputHeight'],
                margin: EdgeInsets.symmetric(
                    vertical: style['dropDownMarginVertical']),
                padding: EdgeInsets.symmetric(
                    horizontal: style['dropDownPaddingHorizontal']),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: style['buttonBorderWidth'],
                  ),
                  borderRadius: BorderRadius.circular(
                      mainStyle['appStyle']['general']['buttonRadius']),
                ),
                child: DropdownButton<String>(
                  value: preferredUnits,
                  underline: Container(),
                  onChanged: (unit) {
                    setButtonState(() {
                      preferredUnits = unit;
                      Provider.of<Distances>(context, listen: false)
                          .setUnit(unit);
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
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: cats.categories.length + 1,
                itemBuilder: (ctx, i) => i != cats.categories.length
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: i == cats.categories.length - 1
                                ? 0.0
                                : style['buttonPadding'],
                            left: style['buttonPadding'],
                            right: style['buttonPadding']),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: style['buttonBorderWidth'],
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(
                              mainStyle['appStyle']['general']['buttonRadius']),
                        ),
                        child: RaisedButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onPressed: () {
                            widget.selectCategory(cats.categories[i]);
                          },
                          child: Row(
                            children: <Widget>[
                              Text(cats.categories[i]),
                            ],
                          ),
                        ),
                      )
                    : StatefulBuilder(
                        builder: (ctx, setBuilderState) {
                          return !_isAdding
                              ? FlatButton.icon(
                                  label: Text('Add Category'),
                                  icon: Icon(Icons.create_new_folder),
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    setBuilderState(() {
                                      _isAdding = true;
                                    });
                                  },
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: style['nameInputHeight'],
                                      margin: EdgeInsets.only(
                                          top: style['buttonPadding'],
                                          left: style['buttonPadding'],
                                          right: style['buttonPadding']),
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              style['inputHorizontalPadding']),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            mainStyle['appStyle']['general']
                                                ['buttonRadius']),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: Center(
                                              child: TextField(
                                                controller: _name,
                                                onChanged: (_) {
                                                  setBuilderState(() {});
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            padding: EdgeInsets.all(
                                                style['iconButtonPadding']),
                                            icon: _isProcessingAdd
                                                ? FittedBox(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ) //Icon(Icons.cloud_upload)
                                                : Icon(
                                                    Icons.check_circle_outline),
                                            onPressed: _name.text == '' ||
                                                    _isProcessingAdd ||
                                                    cats.categories
                                                        .contains(_name.text)
                                                ? null
                                                : () async {
                                                    await addCat();
                                                    _name.clear();
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (cats.categories.contains(_name.text))
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: style['buttonPadding'] + 5),
                                        child: Text(
                                          'Already taken',
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).errorColor,
                                              fontSize: 16),
                                        ),
                                      ),
                                  ],
                                );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
