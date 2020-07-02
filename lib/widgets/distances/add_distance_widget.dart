import 'package:flutter/material.dart';

class AddDistanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Stack(
        children: <Widget>[
          Image.asset('assets/images/distance_markers.jpg'),
          Icon(Icons.add_circle_outline),
        ],
      ),
      footer: GridTileBar(
        title: Text('Add Distance'),
      ),
    );
  }
}
