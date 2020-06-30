import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/sql_helper.dart';
import '../../providers/categories.dart';

class DistanceDrawer extends StatelessWidget {
  DistanceDrawer(this.selectCategory);

  final void Function(String cat) selectCategory;

  @override
  Widget build(BuildContext context) {
    final cats = Provider.of<Categories>(context).categories;

    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Categories'),
            automaticallyImplyLeading: false,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: cats.length + 1,
            itemBuilder: (ctx, i) => i != cats.length
                ? InkWell(
                    onTap: () {
                      selectCategory(cats[i]);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                      ),
                      child: Text(cats[i]),
                    ),
                  )
                : FlatButton(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.add_circle_outline),
                        Text('Add Category')
                      ],
                    ),
                    onPressed: () {
                      categoryDbSetup();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
