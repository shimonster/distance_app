import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/sql_helper.dart';

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
      await addCat(title);
    }
  }

  Future<void> getCategories() async {
    if (uid != null) {
      final cats = await Firestore.instance.document('users/$uid').get();
      _categories = cats.data['categories'];
    } else {
      _categories = await getCats();
    }
  }
}
