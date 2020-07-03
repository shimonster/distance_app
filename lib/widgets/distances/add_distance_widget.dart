import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/pickers/add_distance_track_screen.dart';

class AddDistanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildAddOption(
            IconData icon, String name, BuildContext context, bool isTrack) =>
        InkWell(
          splashColor: Theme.of(context).primaryColorLight,
          onTap: () {
            if (isTrack) {
              Navigator.of(context).pushNamed(AddDistanceTrackScreen.routeName);
            } else {
              Navigator.of(context).pushNamed('PLACE HOLDER');
            }
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  width: 15,
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    name,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildAddOption(
                      Icons.timeline,
                      'A-B-C - Calculated distance between selected pointss',
                      context,
                      false),
                  Divider(),
                  _buildAddOption(
                      Icons.trending_up,
                      'Track - Tracks the distance you travelled',
                      context,
                      true),
                ],
              ),
            ),
          );
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
