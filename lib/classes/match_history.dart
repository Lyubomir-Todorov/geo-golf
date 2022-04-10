import 'package:final_project/classes/guess.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MatchHistory {
  late String date, time, timestamp;
  late double bestDistance;
  late List<Guess> coords;
  late bool favourite;
  late String uid;
  late LatLng actual;
  MatchHistory({required this.date, required this.time, required this.coords, required this.favourite, required this.bestDistance, required this.uid, required this.timestamp, required this.actual});
  factory MatchHistory.fromJson(Map<String, dynamic> json) {

    List<Guess> coords = [];
    for (var element in json['guesses']) {
      coords.add(
        Guess(
          coordinates: LatLng(element['lat'], element['lon']),
          distance : element['distance'],
          quality: GuessRank.values[element['quality']]
        )
      );
    }

    return MatchHistory(
      date: json['date'],
      time: json['time'],
      timestamp: json['timestamp'],
      actual: LatLng(json['actual_location']['lat'], json['actual_location']['lon'] ),
      coords: coords,
      favourite: json['favourite'],
      bestDistance: json['best_distance'],
      uid: json['uid'],
    );
  }
}