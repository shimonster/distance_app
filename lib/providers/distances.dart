import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';

class Distance {
  const Distance({
    this.uid,
    @required this.distance,
    @required this.units,
    @required this.cats,
    @required this.markers,
  });

  final String uid;
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
}
