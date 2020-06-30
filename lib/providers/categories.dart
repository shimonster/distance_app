import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Categories extends ChangeNotifier {
  Categories(this.uid);

  final String uid;
  List<String> _categories = ['All'];

  List<String> get categories {
    return [..._categories];
  }

  Future<void> addCategory(String title) async {
    if (uid != null) {
      await Firestore.instance
          .document('users/$uid')
          .setData({'categories': _categories});
    } else {
      addCategory(title);
    }
  }
}
