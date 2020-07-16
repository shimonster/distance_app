import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/distances/distances_drawer.dart';
import '../../providers/categories.dart';
import '../../providers/distances.dart';
import '../../widgets/distances/add_distance_widget.dart';
import '../../widgets/distances/distance_display_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DistancesScreen extends StatefulWidget {
  DistancesScreen(this.switchMode);

  final void Function() switchMode;
  @override
  _DistancesScreenState createState() => _DistancesScreenState();
}

class _DistancesScreenState extends State<DistancesScreen> {
  var category = 'All';
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
//    setState(() {
//      _isLoading = true;
//    });
//    final cats = Provider.of<Categories>(context, listen: false);
//    Distances(cats.uid, cats.categories, context).getDistances(context).then(
//          (value) => setState(() {
//            print('after get distances initstate');
//            _isLoading = false;
//          }),
//        );
  }

  void rebuild() {
    setState(() {});
  }

  void _selectCategory(String cat) {
    setState(() {
      Navigator.of(context).pop();
      category = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final distances = Provider.of<Distances>(context, listen: false);
    final List<Distance> distanceCats = distances.distances
        .where((element) => element.cat == category)
        .toList();

    return Scaffold(
      drawer: DistanceDrawer(_selectCategory, widget.switchMode),
      appBar: AppBar(
        title: Text(category),
      ),
      body: FutureBuilder(
        future: distances.getDistances(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting /* &&  _isLoading*/
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(10),
                child: GridView.builder(
                  itemCount: category == 'All'
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
                        (category == 'All'
                            ? distances.distances.length
                            : distanceCats.length)) {
                      return DistanceDisplayWidget(
                          category == 'All'
                              ? distances.distances[i].id
                              : distances.distances
                                  .where((element) => element.cat == category)
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
