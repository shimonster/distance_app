import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:latlong/latlong.dart';
import 'package:distanceapp/providers/distances.dart' as d;

class Config {
  Future<Map> getData() async {
    final stringData = await rootBundle.loadString('assets/config.yaml');
    final YamlMap yamlData = loadYaml(stringData);
    print(yamlData);
    final map = {};
    yamlData.forEach((key, value) => map.putIfAbsent(key, () => value));
    return map;
  }

  Marker buildMarker(e) {
    final int calcAlt = (sqrt(max(e['alt'] + 1300, 0)) * 1.84).round();
    return Marker(
      point: e['LatLng'],
      width: 9,
      builder: (ctx) => CircleAvatar(
        backgroundColor: e['alt'] <= 0
            ? Color.fromRGBO(0, 255, 0, 1)
            : e['alt'] > 17000
                ? Colors.white
                : Color.fromRGBO(
                    min((calcAlt).round(), 255),
                    max((255 - calcAlt).round(),
                        (-510 + calcAlt * 2.2).round()),
                    min((calcAlt * 2).round(), 380 - calcAlt),
                    1),
      ),
    );
  }

  Map<String, dynamic> getPathInfo(d.Distance dist, double height) {
    LatLng mostLat;
    LatLng lestLat;
    LatLng mostLng;
    LatLng lestLng;
    double mostAlt;
    double lestAlt;

    dist.markers.forEach((m) {
      final ll = m['LatLng'];
      final a = m['alt'];
      if (mostLat == null) {
        mostLat = ll;
        lestLat = ll;
        mostLng = ll;
        lestLng = ll;
        mostAlt = a;
        lestAlt = a;
      } else if (ll.latitude > mostLat.latitude) {
        mostLat = ll;
      } else if (ll.latitude < lestLat.latitude) {
        lestLat = ll;
      } else if (ll.longitude > mostLng.longitude) {
        mostLng = ll;
      } else if (ll.longitude < lestLng.longitude) {
        lestLng = ll;
      }

      if (a > mostAlt) {
        mostAlt = a;
      } else if (a < lestAlt) {
        lestAlt = a;
      }
    });

    final latDist = Distance().as(LengthUnit.Meter, lestLat, mostLat);
    final lngDist = Distance().as(LengthUnit.Meter, lestLng, mostLng);

    final zoom = (sqrt(max(latDist, lngDist)) * 0.07 + 3.5) * (height / 250);

    final center = LatLng(
        lestLat.latitude + ((mostLat.latitude - lestLat.latitude) / 2),
        lestLng.longitude + ((mostLng.longitude - lestLng.longitude) / 2));

    return {
      'zoom': 19 - zoom,
      'center': center,
      'minAlt': lestAlt,
      'maxAlt': mostAlt
    };
  }
}
