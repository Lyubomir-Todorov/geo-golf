import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'guess.dart';

class GameData {
  late LatLng actualPosition;
  late int guessesRemaining;
  late int markerId;
  late List<Guess> guesses;
  late Map<MarkerId, Marker> markers;
  late Future<double> zoom;

  GameData(this.actualPosition, this.guessesRemaining, this.markerId, this.guesses, this.markers, this.zoom);

}