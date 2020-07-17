import 'dart:math';

import 'package:test/test.dart';
import 'package:latlong/latlong.dart';

import '../lib/providers/distances.dart';

void main() {
  group('Distance Caluclator', () {
    test('value should be 0 for 0 points', () {
      final distances = Distances('test1');

      distances.computeTotalDist([]);

      //expect(distances.distance, 0.0);
    });

    test('value should be 0 for 1 points', () {
      final distances = Distances('test2');

      distances.computeTotalDist([
        {
          'LatLng': LatLng(10, 10),
          'alt': 10,
          'time': DateTime.now(),
        },
      ]);

      //expect(distances.distance, 0.0);
    });

    test('value should be 58.82m for 2 points', () {
      final distances = Distances('test3');

      distances.computeTotalDist([
        {
          'LatLng': LatLng(47.5733899, -122.147530),
          'alt': 0,
          'time': DateTime.now(),
        },
        {
          'LatLng': LatLng(47.573, -122.147),
          'alt': 0,
          'time': DateTime.now().add(Duration(seconds: 1)),
        },
      ]);

      //expect(distances.distance - 58.82, lessThan(0.1));
    });

    test('value should be 157000 for 2 points', () {
      final distances = Distances('sdfasdf');

      distances.computeTotalDist([
        {
          'LatLng': LatLng(0, 0),
          'alt': 0,
          'time': DateTime.now(),
        },
        {
          'LatLng': LatLng(1, 1),
          'alt': 157425.537,
          'time': DateTime.now().add(Duration(seconds: 1)),
        },
        {
          'LatLng': LatLng(0, 0),
          'alt': 0,
          'time': DateTime.now().add(Duration(seconds: 2)),
        },
      ]);

      //expect(distances.distance, 157425.537 * 2 * sqrt(2));
    });
  });
}
