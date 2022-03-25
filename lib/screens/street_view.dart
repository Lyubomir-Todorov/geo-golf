import 'package:final_project/data/country_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:math' as math;

math.Random ran = math.Random.secure();

class Coordinates {
  late double latitude, longitude;
  Coordinates(this.latitude, this.longitude);
}

class StreetView extends StatefulWidget {
  @override
  State<StreetView> createState() => _StreetViewState();
}

class _StreetViewState extends State<StreetView> {
  StreetViewController? streetViewController;
  late LatLng _coordinates;
  double _searchRadius = 5;

  _generateValidCoordinates() {
    var randomArea = areasToSearch[ran.nextInt(areasToSearch.length)];
    setState(() {
      _coordinates = randomArea.getRandomPointWithinRadius();
      _searchRadius *= _searchRadius;
    });
  }

  _gotoGuessing() {
    Navigator.pushNamed(
      context, '/country',
      arguments: Coordinates(_coordinates.latitude, _coordinates.longitude)
    );
  }

  @override
  void initState() {
    super.initState();
    _generateValidCoordinates();
    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Center(child: Text(''))
      ),
      body: SafeArea(
        top: false,
        child: FlutterGoogleStreetView(
          initPos: LatLng(_coordinates.latitude, _coordinates.longitude),
          initRadius: _searchRadius,

          // TODO -> Play around with the app and see if you get a lot of indoor panos
          initSource: StreetViewSource.def,
          // initSource: StreetViewSource.outdoor,

          streetNamesEnabled: false,
          // userNavigationEnabled: false,

          onStreetViewCreated: (StreetViewController controller) async {
            streetViewController = controller;
          },

          onPanoramaChangeListener: (location, e) {
            print("location:$location, e:$e");
            if (location == null) {
              print("No location found, trying another set of coordinates");
              _generateValidCoordinates();
            }
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Guess",
        child: const FaIcon(FontAwesomeIcons.earthAmericas),
        onPressed: () { _gotoGuessing(); },
      ),
    );
  }
}

