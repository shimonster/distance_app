import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;

import '../helpers/sql_helper.dart';

class Distance {
  const Distance({
    @required this.id,
    @required this.name,
    @required this.time,
    @required this.distance,
    @required this.units,
    @required this.cat,
    @required this.markers,
  });

  final String id;
  final String name;
  final DateTime time;
  final double distance;
  final String units;
  final String cat;
  final List<Map<String, dynamic>> markers;
}

class Distances extends ChangeNotifier {
  Distances(this.uid, this.categories, [this._distances]);

  final String uid;
  final String preferredUnit = 'Meters';
  final List<String> categories;
  List<Distance> _distances = [];

  List<Distance> get distances {
    return [..._distances];
  }

  double computeTotalDist(List<Map<String, dynamic>> markers) {
    var distance = 0.0;
    Map<String, dynamic> prevPoint;
    markers.forEach((element) {
      if (prevPoint != null) {
        final flatDis = mt.SphericalUtil.computeLength([
          mt.LatLng(
              prevPoint['LatLng'].latitude, prevPoint['LatLng'].longitude),
          mt.LatLng(element['LatLng'].latitude, element['LatLng'].longitude),
        ]);
        final calcDis =
            sqrt(pow(flatDis, 2) + pow((element['alt'] - prevPoint['alt']), 2));
        distance += calcDis;
      }
      prevPoint = element;
    });
    return distance;
  }

  Future<DocumentSnapshot> addToDatabase(
      String name,
      DateTime time,
      String units,
      String category,
      List<Map<String, dynamic>> markers,
      double distance) async {
    final result = await Firestore.instance
        .collection('users/$uid/distances')
        .document()
        .get();
    await result.reference.setData({
      'name': name,
      'time': time.toString(),
      'distance': distance,
      'units': units,
      'category': category,
      'markers': markers
          .map((e) => {
                'lat': e['LatLng'].latitude,
                'lng': e['LatLng'].longitude,
                'alt': e['alt'],
                'time': e['time'].toString(),
              })
          .toList(),
    });
    return result;
  }

  Future<void> addDistance(
      String name,
      DateTime time,
      String units,
      String category,
      List<Map<String, dynamic>> markers,
      double distance) async {
    try {
      //final distance = computeTotalDist(markers);
      final newMarks = markers
          .map((e) => {
                'lat': (e['LatLng'].latitude * 100000000).round(),
                'lng': (e['LatLng'].longitude * 100000000).round(),
                'alt': e['alt'],
                'time': e['time'].toString(),
              })
          .toList();
      if (uid != null) {
        final result =
            await addToDatabase(name, time, units, category, markers, distance);
        SQLHelper.addDistance(
            result.documentID, name, units, category, newMarks, uid);
        _distances.add(
          Distance(
            id: result.documentID,
            name: name,
            time: time,
            distance: distance,
            units: units,
            cat: category,
            markers: markers,
          ),
        );
      } else {
        SQLHelper.addDistance(
            time.toIso8601String(), name, units, category, markers, '');
        _distances.add(
          Distance(
            id: time.toIso8601String(),
            name: name,
            time: time,
            distance: distance,
            units: units,
            cat: category,
            markers: markers,
          ),
        );
      }
      notifyListeners();
    } on PlatformException catch (error) {
      throw error;
    } catch (error) {
      throw error;
    }
  }

  Future<void> getDistances() async {
    try {
      if (uid != null) {
        final result = await Firestore.instance
            .collection('users/$uid/distances')
            .getDocuments();
        List<Distance> loadedDistances = [];
        result.documents.forEach((dist) {
          final List<Map<String, dynamic>> marks = dist.data['markers']
              .map<Map<String, dynamic>>((mar) => {
                    'LatLng': LatLng(mar['lat'], mar['lng']),
                    'alt': mar['alt'],
                    'time': DateTime.parse(mar['time'])
                  })
              .toList();
          marks.sort((a, b) => a['time'].isAfter(b['time']) ? 1 : -1);
          loadedDistances.add(
            Distance(
              id: dist.documentID,
              name: dist.data['name'],
              time: DateTime.parse(dist.data['time']),
              distance: dist.data['distance'],
              units: dist.data['units'],
              cat: dist.data['category'],
              markers: marks,
            ),
          );
        });
        loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
        print(loadedDistances);
        _distances = loadedDistances;
        notifyListeners();
      } else {
        final loadedDistances = await SQLHelper.getDistances(uid ?? '');
        loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
        _distances = loadedDistances;
        notifyListeners();
      }
    } on PlatformException catch (error) {
      final loadedDistances =
          await SQLHelper.getDistances(uid ?? DateTime.now());
      loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
      _distances = loadedDistances;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
