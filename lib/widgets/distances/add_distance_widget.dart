import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:distanceapp/screens/pickers/add_distance_track_screen.dart';

class AddDistanceWidget extends StatelessWidget {
  AddDistanceWidget(this.rebuild);

  final void Function() rebuild;
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Theme.of(context).accentColor,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(AddDistanceTrackScreen.routeName)
                .then((value) => rebuild());
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
      ),
    );
  }
}
