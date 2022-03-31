import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';

import '../classes/guess.dart';
import '../classes/results.dart';

class MatchResults extends StatefulWidget {
  const MatchResults({Key? key}) : super(key: key);

  @override
  _MatchResultsState createState() => _MatchResultsState();
}

class _MatchResultsState extends State<MatchResults> {

  bool _resultsInit = false;
  bool _shownAsPreviousMatch = false;

  GoogleMapController? _controller;
  final PanelController panelController = PanelController();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  List<Guess> _guesses = [];
  double? _bestDistance;

  // TODO -> Adjust zoom level according to best distance (closer = more zoomed in)

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _guesses.last.coordinates, zoom: 4)
      ),
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
    var args = ModalRoute.of(context)!.settings.arguments as Results;

    setState(() {
      _resultsInit = true;
      _markers = args.markers;
      _guesses = args.guesses;
      _shownAsPreviousMatch = args.isHistorical;

      var t = _guesses.map((v) => v).toList();
      t.removeLast();

      _bestDistance = t.reduce(
          (value, element) => value.distance < element.distance ? value : element
      ).distance;
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

      var uid = nanoid();

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
        'uid' : uid,
        'date' : DateFormat('MMMM dd, y').format(now),
        'time' : DateFormat('hh:mm').format(now),
        'best_distance' : _bestDistance,
        'guesses' : guessesFormatted,
        'favourite' : false,
        'actual_location': {
          "lat":_guesses.last.coordinates.latitude,
          "lon":_guesses.last.coordinates.longitude,
        }
      };

      // TRY WITHOUT SUBCOLLECTIONS

      matches.set({
        uid : obj,
      },
      SetOptions(merge : true)).then((value) => print("Match history Added"))
        .catchError((error) => print("Failed to add match history: $error"));

    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (!_resultsInit) {
      _loadMapData();

      // Only add to Firebase if we have navigated from an actual game
      if (!_shownAsPreviousMatch) _addToMatchHistory();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Match Results'),
      ),
      body: SlidingUpPanel(
        minHeight: _shownAsPreviousMatch ? 48 : 96,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        controller: panelController,
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          initialCameraPosition: const CameraPosition(
            target: LatLng(30, -45),
          ),
          markers: Set<Marker>.of(_markers.values),
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
                    Center(child: Text('You were $_bestDistance km away!')),
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
                    return Card(
                      elevation: 3.0,
                      child: ListTile(
                        title: Text("Attempt ${index+1}"),
                        subtitle: Text("${_guesses[index].distance} km"),
                        trailing: IconButton(
                          onPressed: () {
                            _moveCamera(_guesses[index].coordinates);
                            _closeDrawer();
                          },
                          tooltip: "Find on map",
                          icon: const FaIcon(FontAwesomeIcons.magnifyingGlassLocation),
                        )
                      ),
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
