import 'package:flutter/foundation.dart';

enum sc {
  colors,
  distanceDisplayWidget,
  distancesScreen,
  authCard,
  addTrackScreen,
  distanceDetailsScreen,
  addTrackScreenFunction,
}

class Style extends ChangeNotifier {
  List<double> primaryLight;
  List<double> primary;
  List<double> primaryDark;
  List<double> accent;
  List<double> scaffold;
  List<double> appBarText;
  List<double> buttonText;
  List<double> buttonColor;
}
