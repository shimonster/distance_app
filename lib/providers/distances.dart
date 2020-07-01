import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String time;
  final double distance;
  final String units;
  final String cat;
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

  Future<void> addDistance(double distance, String name, DateTime time,
      String units, String category, List<Map<String, dynamic>> markers) async {
    try {
      if (uid != null) {
        await Firestore.instance
            .collection('users/$uid/distances')
            .document()
            .setData({
          'distance': distance,
          'units': units,
          'category': category,
          'markers': markers,
        });
        final result =
            await Firestore.instance.document('users/$uid/distances').get();
        SQLHelper.addDistance(
            result.documentID, name, units, category, markers);
      } else {
        SQLHelper.addDistance(
            time.toIso8601String(), name, units, category, markers);
      }
      notifyListeners();
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
        result.documents.forEach((element) {
          loadedDistances.add(Distance(
            id: element.documentID,
            name: element.data['name'],
            time: element.data['time'],
            distance: element.data['distance'],
            units: element.data['units'],
            cat: element.data['category'],
            markers: element.data['markers'].map((element) {
              return LatLng(
                  element['LatLng'].latitude, element['LatLng'].longitude);
            }),
          ));
        });
        _distances = loadedDistances;
      } else {
        _distances = await SQLHelper.getDistances();
      }
    } on PlatformException catch (error) {
      _distances = await SQLHelper.getDistances();
    } catch (error) {
      throw error;
    }
  }
}
