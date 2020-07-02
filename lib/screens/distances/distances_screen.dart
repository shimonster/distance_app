import 'package:distanceapp/helpers/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';

import '../../widgets/distances/distances_drawer.dart';
import '../../providers/categories.dart';
import '../../providers/distances.dart';

class DistancesScreen extends StatefulWidget {
  @override
  _DistancesScreenState createState() => _DistancesScreenState();
}

class _DistancesScreenState extends State<DistancesScreen> {
  var category = 'All';
  List<String> cats;

  @override
  void initState() {
    super.initState();
    cats = Provider.of<Categories>(context, listen: false).categories;
    Provider.of<Distances>(context, listen: false).getDistances();
  }

  void _selectCategory(String cat) {
    setState(() {
      Navigator.of(context).pop();
      category = cat;
    });
  }

  Future<void> addCategory(TextEditingController _name) {
    return Provider.of<Categories>(context)
        .addCategory(_name.text)
        .then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    final distances = Provider.of<Distances>(context);

    return Scaffold(
      drawer: DistanceDrawer(_selectCategory, addCategory),
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: distances.distances.length,
        itemBuilder: (ctx, i) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              Text(distances.distances[i].name.toString()),
              SizedBox(
                width: 10,
              ),
              Text(distances.distances[i].time.toString()),
              SizedBox(
                width: 10,
              ),
              Text(distances.distances[i].distance.toString()),
              SizedBox(
                width: 10,
              ),
              Text(distances.distances[i].units.toString()),
              SizedBox(
                width: 10,
              ),
              Text(distances.distances[i].cat.toString()),
              SizedBox(
                width: 10,
              ),
              Text(distances.distances[i].markers.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
