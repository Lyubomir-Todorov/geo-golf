import 'package:google_maps_flutter/google_maps_flutter.dart';

class MatchHistory {
  late String date, time;
  late double bestDistance;
  late List<LatLng> coords;
  late bool favourite;
  late String uid;
  MatchHistory(this.date, this.time, this.coords, this.favourite, this.bestDistance, this.uid);
}