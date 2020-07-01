import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/sql_helper.dart';

class Distance {
  const Distance({
    @required this.id,
    @required this.distance,
    @required this.units,
    @required this.cats,
    @required this.markers,
  });

  final String id;
  final double distance;
  final String units;
  final List<String> cats;
  final List<LatLng> markers;
}

class Distances extends ChangeNotifier {
  Distances(this.uid, this.categories, [this._distances]);

  final String uid;
  final List<String> categories;
  List<Distance> _distances = [];

  List<Distance> get distances {
    return [..._distances];
  }

  Future<void> addDistance(Distance distance) async {
    if (uid != null) {
      final putLoc =
          await Firestore.instance.document('users/$uid/distances').get();
    }
  }
}
