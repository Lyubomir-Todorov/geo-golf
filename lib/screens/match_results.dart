import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:georange/georange.dart';
import 'package:confetti/confetti.dart';

import '../classes/guess.dart';
import '../classes/toast.dart';
import '../enum/distance.dart';
import 'stats.dart' as stats;

GeoRange georange = GeoRange();

class MatchResults extends StatefulWidget {
  const MatchResults({Key? key}) : super(key: key);

  @override
  _MatchResultsState createState() => _MatchResultsState();
}

class _MatchResultsState extends State<MatchResults> {

  bool _resultsInit = false;
  bool _shownAsPreviousMatch = false;
  bool _favourite = false;
  late Distance _unit;
  late String _uid;
  late ConfettiController _confettiController;

  GoogleMapController? _controller;
  final PanelController panelController = PanelController();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  List<Guess> _guesses = [];
  Guess? _bestGuess;
  double? _bestDistance;

  // TODO -> Adjust zoom level according to best distance (closer = more zoomed in)
  // TODO -> Get the two markers always within zoom

  double distanceToZoom(LatLng pointA, LatLng pointB) {
    // The smaller the distance > Larger the zoom
    // 1 km ~ 14.7
    // 3 km ~ 13
    // 137 km ~ 8.5
    // 300 km ~ 7
    // 600 km ~ 5

    var threshold = 1000;

    double distance = georange.distance(
      Point(latitude: pointA.latitude, longitude: pointA.longitude),
      Point(latitude: pointB.latitude, longitude: pointB.longitude),
    );
    print(distance);

    return (threshold / (distance+0.01));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    /*
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _guesses.last.coordinates, zoom: distanceToZoom(_guesses.last.coordinates, _bestGuess!.coordinates))
      ),
    );
    */
    
    _controller?.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
            northeast: _guesses.last.coordinates, southwest: _bestGuess!.coordinates
        ),
        50
      )
    );
  }

  _moveCamera(LatLng target) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 4)
      ),
    );
  }

  _playAnother() {
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    Navigator.pushNamed(context, '/streetview');
  }

  _loadMapData() {

    var args = ModalRoute.of(context)?.settings.arguments as stats.ScreenArguments;

    setState(() {
      _resultsInit = true;
      _markers = args.results.markers;
      _guesses = args.results.guesses;
      _shownAsPreviousMatch = args.results.isHistorical;
      _favourite = args.favourite;
      _uid = args.uid;
      _unit = args.unit;

      var t = _guesses.map((v) => v).toList();
      t.removeLast();

      _bestGuess = t.reduce(
        (value, element) => value.distance < element.distance ? value : element
      );
      _bestDistance=_bestGuess?.distance;
    });

  }

  _closeDrawer() {
    panelController.close();
  }

  _addToMatchHistory() async {
    try {
      DocumentReference matches = FirebaseFirestore.instance.collection('match_history')
          .doc(FirebaseAuth.instance.currentUser?.uid);

      DateTime now = DateTime.now();

      // Removes the actual coordinate
      var t = _guesses.map((v) => v).toList();
      t.removeLast();

      final guessesFormatted = [];
      for (var element in t) {
        guessesFormatted.add({
          "lat":element.coordinates.latitude,
          "lon":element.coordinates.longitude,
          "distance":element.distance,
          "quality":element.quality.index,
        });
      }

      var obj = {
        'uid' : _uid,
        'date' : DateFormat('MMMM dd, y').format(now),
        'time' : DateFormat('hh:mm').format(now),
        'timestamp' : DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
        'best_distance' : _bestDistance,
        'guesses' : guessesFormatted,
        'favourite' : false,
        'actual_location': {
          "lat":_guesses.last.coordinates.latitude,
          "lon":_guesses.last.coordinates.longitude,
        }
      };

      matches.set({
        _uid : obj,
      },
      SetOptions(merge : true)).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Failed to add match to history"));

    } on FirebaseAuthException catch (e) {
      Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, e.toString());
    }
  }

  _incrementPlayerStats() {
    try {
      DocumentReference doc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);

      doc.update({
        "xp" : FieldValue.increment(5),
        "points" : FieldValue.increment(1),
      }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error updating profile!"));

    } on FirebaseAuthException catch (e) {
      Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, e.toString());
    }
  }

  _toggleFavourite() {
    setState(() {
      _favourite = !_favourite;
    });
    try {
      DocumentReference matches = FirebaseFirestore.instance.collection('match_history').doc(FirebaseAuth.instance.currentUser?.uid);

      matches.update({
        "$_uid.favourite" : _favourite,
      }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error updating match!"));

    } on FirebaseAuthException catch (e) {
      Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!_resultsInit) {
      _loadMapData();
      _confettiController = ConfettiController(duration: const Duration(seconds: 1));
      // Only add to Firebase if we have navigated from an actual game
      if (!_shownAsPreviousMatch) {
        _addToMatchHistory();
        _incrementPlayerStats();
        if (GuessQuality.getRank(_bestDistance!) == GuessRank.excellent) {
          _confettiController.play();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Match Results'),
        actions: [
          IconButton(
            onPressed: () {
              _toggleFavourite();
            },
            icon: FaIcon(
              _favourite ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star
            ),
            tooltip: _favourite ? "Remove from favourites" : "Add to favourites",
            color: Colors.orange,
            iconSize: 20,
          )
        ],
      ),
      body: SlidingUpPanel(
        minHeight: _shownAsPreviousMatch ? 48 : 96,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        controller: panelController,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              onCameraMoveStarted: () => (_controller!.getZoomLevel().then((value) => print(value))),
              initialCameraPosition: const CameraPosition(
                target: LatLng(30, -45),
              ),
              markers: Set<Marker>.of(_markers.values),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                emissionFrequency: 0,
                maxBlastForce: 50,
                shouldLoop: false,
                confettiController: _confettiController,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
                blastDirectionality: BlastDirectionality
                    .explosive, // don't specify a direction, blast randomly
              ),
            ),
          ],
        ),

        panel: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child:
                      _unit == Distance.imperial ?
                      Text('You were ${DistanceConversion.getDistanceAsImperial(_bestDistance!, 0)} away!'):
                      Text('You were ${DistanceConversion.getDistanceAsMetric(_bestDistance!, 0)} away!')
                    ),
                    Visibility(
                      visible: !_shownAsPreviousMatch,
                      child: ElevatedButton(
                        onPressed: _playAnother,
                        child: const Text('Play another')
                      )
                    )
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: _guesses.length-1,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text("Attempt ${index+1}"),
                          subtitle:
                          _unit == Distance.imperial ?
                          Text(DistanceConversion.getDistanceAsImperial(_guesses[index].distance, 0)):
                          Text(DistanceConversion.getDistanceAsMetric(_guesses[index].distance, 0)),
                          trailing: IconButton(
                            onPressed: () {
                              _moveCamera(_guesses[index].coordinates);
                              _closeDrawer();
                            },
                            tooltip: "Find on map",
                            icon: const FaIcon(FontAwesomeIcons.magnifyingGlassLocation),
                          )
                        ),
                        const Divider(thickness: 2)
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
