import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';

class Distance {
  const Distance(this.distance, this.markers, this.units);

  final double distance;
  final String units;
  final List<LatLng> markers;
}

class Distances extends ChangeNotifier {
  Distances(this.isAuth);

  final bool isAuth;
}
