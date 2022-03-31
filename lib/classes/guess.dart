import 'package:google_maps_flutter/google_maps_flutter.dart';

enum GuessRank {
  excellent,
  good,
  fair,
  bad,
}

class Guess {
  late LatLng coordinates;
  late double distance;
  late GuessRank quality;

  Guess(this.coordinates, this.distance, this.quality);

  BitmapDescriptor getMarkerColor() {
    switch(quality) {
      case GuessRank.excellent: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case GuessRank.good: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case GuessRank.fair: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case GuessRank.bad: return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }
}