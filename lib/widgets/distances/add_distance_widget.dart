import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/pickers/add_distance_track_screen.dart';

class AddDistanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AddDistanceTrackScreen.routeName);
        },
        child: GridTile(
          child: Stack(
            children: <Widget>[
              Image.asset(
                'assets/images/distance_markers.jpg',
                fit: BoxFit.cover,
                height: 200,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 45),
                child: Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 100,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
            ],
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text('Add Distance'),
          ),
        ),
      ),
    );
  }
}
