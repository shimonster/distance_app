import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:distanceapp/widgets/categories/distances_drawer.dart';
import 'package:distanceapp/providers/categories.dart';
import 'package:distanceapp/providers/distances.dart';
import 'package:distanceapp/widgets/distances/add_distance_widget.dart';
import 'package:distanceapp/widgets/distances/distance_display_widget.dart';
import 'package:distanceapp/screens/pickers/add_distance_track_screen.dart';
import 'package:distanceapp/main.dart';

class DistancesScreen extends StatefulWidget {
  DistancesScreen(this.switchMode);

  final void Function() switchMode;
  @override
  _DistancesScreenState createState() => _DistancesScreenState();
}

class _DistancesScreenState extends State<DistancesScreen>
    with TickerProviderStateMixin {
  var _category = 'All';
  var _isLoading = true;
  var _hasDisposed = false;
  AnimationController _animationController;
  Animation _offsetAnimation;
  bool _isFirstTime = true;
  Map mainStyle;
  Map style;

  @override
  void initState() {
    super.initState();
    mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    style = mainStyle['appStyle']['distancesScreen'];
    Provider.of<Categories>(context, listen: false)
        .getCategories()
        .then(
          (_) => !_hasDisposed
              ? Provider.of<Distances>(context, listen: false).getUnits()
              : null,
        )
        .then((_) => !_hasDisposed
            ? Provider.of<Distances>(context, listen: false)
                .getDistances(context)
            : null)
        .then(
          (_) => !_hasDisposed
              ? setState(() {
                  _isLoading = false;
                })
              : null,
        );
  }

  @override
  void dispose() {
    _hasDisposed = true;
    if (_animationController != null) _animationController.stop();
    super.dispose();
  }

  void rebuild() {
    _isFirstTime = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final distances = Provider.of<Distances>(context, listen: false);
    final List<Distance> distanceCats = distances.distances
        .where((element) => element.cat == _category)
        .toList();

    void _selectCategory(String cat) {
      setState(() {
        Navigator.of(context).pop();
        _category = cat;
      });
    }

//    final offsetStart = ((Provider.of<Distances>(context, listen: false)
//                    .distances
//                    .where((element) =>
//                        _category == 'All' ? true : element.cat == _category)
//                    .length +
//                1) /
//            ((/*MediaQuery.of(context).size.width / style['maxCrossAxisExtent']*/ 2)
//                .ceil()))
//        .ceil();
    _animationController = AnimationController(
      duration: Duration(
//          milliseconds: offsetStart * style['multiplyOffsetDuration'] +
//              style['addOffsetDuration']),
          milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(-2.5, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(curve: Curves.easeOutQuad, parent: _animationController),
    );

    return Scaffold(
      drawer: DistanceDrawer(
          _selectCategory, widget.switchMode, _animationController),
      appBar: AppBar(
        title: Text(_category),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: style['appBarAddIconSize'],
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AddDistanceTrackScreen.routeName)
                  .then((value) => _isFirstTime = true);
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              itemCount: _category == 'All'
                  ? distances.distances.length + 1
                  : distanceCats.length + 1,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: style['spacing'],
                crossAxisSpacing: style['spacing'],
                childAspectRatio: style['aspectRatio'],
                maxCrossAxisExtent: style['maxCrossAxisExtent'],
              ),
              padding: EdgeInsets.all(style['spacing']),
              itemBuilder: (ctx, i) {
                if (_isFirstTime)
                  _animationController
                      .forward()
                      .then((value) => _isFirstTime = false);
                if (i !=
                    (_category == 'All'
                        ? distances.distances.length
                        : distanceCats.length)) {
                  return SlideTransition(
                    position: _offsetAnimation,
                    child: DistanceDisplayWidget(
                      _category == 'All'
                          ? distances.distances[i].id
                          : distances.distances
                              .where((element) => element.cat == _category)
                              .toList()[i]
                              .id,
                      rebuild,
                      ValueKey(distances.distances[i].id),
                    ),
                  );
                } else {
                  return SlideTransition(
                    position: _offsetAnimation,
                    child: AddDistanceWidget(rebuild),
                  );
                }
              },
            ),
    );
  }
}
