import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/distances/distances_drawer.dart';
import '../../providers/categories.dart';

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
  }

  void _selectCategory(String cat) {
    setState(() {
      Navigator.of(context).pop();
      category = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DistanceDrawer(_selectCategory),
      appBar: AppBar(
        title: Text(category),
      ),
    );
  }
}
