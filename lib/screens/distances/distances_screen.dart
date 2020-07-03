import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/distances/distances_drawer.dart';
import '../../providers/categories.dart';
import '../../providers/distances.dart';
import '../../widgets/distances/add_distance_widget.dart';
import '../../widgets/distances/distance_display_widget.dart';

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
      body: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          itemCount: distances.distances.length + 1,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 6 / 5,
            maxCrossAxisExtent: 300,
          ),
          itemBuilder: (ctx, i) => i != distances.distances.length
              ? DistanceDisplayWidget()
              : AddDistanceWidget(),
        ),
      ),
    );
  }
}
