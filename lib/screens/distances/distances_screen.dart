import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/categories/distances_drawer.dart';
import '../../providers/categories.dart';
import '../../providers/distances.dart';
import '../../widgets/distances/add_distance_widget.dart';
import '../../widgets/distances/distance_display_widget.dart';

class DistancesScreen extends StatefulWidget {
  DistancesScreen(this.switchMode);

  final void Function() switchMode;
  @override
  _DistancesScreenState createState() => _DistancesScreenState();
}

class _DistancesScreenState extends State<DistancesScreen> {
  var _category = 'All';
  var _isLoading = true;
  var _hasDisposed = false;

  @override
  void initState() {
    super.initState();
    Provider.of<Categories>(context, listen: false)
        .getCategories()
        .then(
          (value) => !_hasDisposed
              ? Provider.of<Distances>(context, listen: false).getUnits()
              : null,
        )
        .then(
          (value) => !_hasDisposed
              ? setState(() {
                  _isLoading = false;
                })
              : null,
        );
  }

  @override
  void dispose() {
    _hasDisposed = true;
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void _selectCategory(String cat) {
    setState(() {
      Navigator.of(context).pop();
      _category = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final distances = Provider.of<Distances>(context, listen: false);
    final List<Distance> distanceCats = distances.distances
        .where((element) => element.cat == _category)
        .toList();
    print('from diistances screen: ${distances.preferredUnit}');

    return Scaffold(
      drawer: DistanceDrawer(_selectCategory, widget.switchMode),
      appBar: AppBar(
        title: Text(_category),
      ),
      body: FutureBuilder(
        future: distances.getDistances(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting || _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: GridView.builder(
                      itemCount: _category == 'All'
                          ? distances.distances.length + 1
                          : distanceCats.length + 1,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 6 / 5,
                        maxCrossAxisExtent: 300,
                      ),
                      itemBuilder: (ctx, i) {
                        if (i !=
                            (_category == 'All'
                                ? distances.distances.length
                                : distanceCats.length)) {
                          return DistanceDisplayWidget(
                              _category == 'All'
                                  ? distances.distances[i].id
                                  : distances.distances
                                      .where(
                                          (element) => element.cat == _category)
                                      .toList()[i]
                                      .id,
                              ValueKey(distances.distances[i].id));
                        } else {
                          return AddDistanceWidget(rebuild);
                        }
                      },
                    ),
                  ),
      ),
    );
  }
}
