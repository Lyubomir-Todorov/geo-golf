import 'package:final_project/classes/guess.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Results {
  late List<Guess> guesses;
  late Map<MarkerId, Marker> markers;
  late bool isHistorical;
  Results(this.guesses, this.markers, {this.isHistorical = false});
}