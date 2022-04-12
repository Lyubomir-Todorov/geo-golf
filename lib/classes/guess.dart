import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../enum/distance.dart';

enum GuessRank {
  excellent,
  good,
  fair,
  bad,
}

abstract class GuessQuality {

  static const int distanceExcellent = 10;
  static const int distanceGood = 250;
  static const int distanceFair = 500;


  static GuessRank getRank (double distance, {Distance unit = Distance.metric}) {

    var dExcellent = (unit==Distance.metric) ? distanceExcellent : (distanceExcellent * DistanceConversion.kmToMi);
    var dGood = (unit==Distance.metric) ? distanceGood : (distanceGood * DistanceConversion.kmToMi);
    var dFair = (unit==Distance.metric) ? distanceFair : (distanceFair * DistanceConversion.kmToMi);

    if (distance < dExcellent) {
      return GuessRank.excellent;
    } else if (distance < dGood) {
      return GuessRank.good;
    } else if (distance < dFair) {
      return GuessRank.fair;
    } else {
      return GuessRank.bad;
    }
  }

  static String getRankAsDescriptor(GuessRank rank) {
    switch(rank) {
      case(GuessRank.excellent): return "Excellent";
      case(GuessRank.good): return "Good";
      case(GuessRank.fair): return "Okay";
      case(GuessRank.bad): return "Bad";
      default: return "";
    }
  }

  static String getRankAsRangeDescriptor(GuessRank rank, {Distance unit = Distance.metric}) {
    switch(rank) {
      case(GuessRank.excellent): return "Within ${(unit==Distance.metric) ? distanceExcellent : (distanceExcellent * DistanceConversion.kmToMi).toStringAsFixed(0)} ${(unit==Distance.imperial) ? "mi" : "km"}";
      case(GuessRank.good): return "Within ${(unit==Distance.metric) ? distanceGood : (distanceGood * DistanceConversion.kmToMi).toStringAsFixed(0)} ${(unit==Distance.imperial) ? "mi" : "km"}";
      case(GuessRank.fair): return "Within ${(unit==Distance.metric) ? distanceFair : (distanceFair * DistanceConversion.kmToMi).toStringAsFixed(0)} ${(unit==Distance.imperial) ? "mi" : "km"}";
      case(GuessRank.bad): return "Everything else";
      default: return "";
    }
  }
}

class Guess {
  late LatLng coordinates;
  late double distance;
  late GuessRank quality;
  late Distance unit;

  Guess({required this.coordinates, required this.distance, required this.quality});

  BitmapDescriptor getMarkerColor() {
    switch(quality) {
      case GuessRank.excellent: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case GuessRank.good: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case GuessRank.fair: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case GuessRank.bad: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }
}