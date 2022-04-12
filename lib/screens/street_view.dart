import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/country_data.dart';
import 'package:final_project/screens/country_select.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:math' as math;

import '../classes/toast.dart';
import '../enum/distance.dart';

math.Random ran = math.Random.secure();

class Coordinates {
  late double latitude, longitude;
  Coordinates(this.latitude, this.longitude);
}

class StreetView extends StatefulWidget {
  const StreetView({Key? key}) : super(key: key);

  @override
  State<StreetView> createState() => _StreetViewState();
}

class _StreetViewState extends State<StreetView> {

  StreetViewController? streetViewController;
  final PanelController panelController = PanelController();

  late LatLng _coordinates;
  late String _streetViewId;
  double _searchRadius = 5;
  bool _locationFound = false;
  bool _panelIsOpen = false;
  Distance _unit = Distance.metric;

  _getUserInfo() async {
    DocumentReference users = FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
          _unit = Distance.values[value.data()!['unit']];
    }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error getting user info!")) as DocumentReference<Object?>;
  }

  _generateValidCoordinates() {
    var randomArea = areasToSearch[ran.nextInt(areasToSearch.length)];
    setState(() {
      try {
        _coordinates = randomArea.getRandomPointWithinRadius();

        // Use this one when you're testing just so you dont eat up the street view api
        // _coordinates = LatLng(37.63613, -96.30114499999999);
      } catch (a) {
        _generateValidCoordinates();
        _searchRadius = 5;
      }
      _searchRadius *= 2;
    });
  }

  _foundLocation() {
    setState(() {
      _locationFound = true;
    });
  }

  _setPanoId(String? id) {
    setState(() {
      _streetViewId = id!;
    });
  }

  _gotoInitialStreetView() async {
    setState(() {
      streetViewController!.setPosition(panoId: _streetViewId);
    });
  }

  _enableStreetViewGestures() {
    setState(() {
      _panelIsOpen = false;
      streetViewController?.setZoomGesturesEnabled(true);
      streetViewController?.setPanningGesturesEnabled(true);
    });
  }

  _disableStreetViewGestures() {
    setState(() {
      _panelIsOpen = true;
      streetViewController?.setZoomGesturesEnabled(false);
      streetViewController?.setPanningGesturesEnabled(false);
    });
  }

  _togglePanel() {
    setState(() {
      if (panelController.isPanelOpen) {
        panelController.close();
      } else {
        panelController.open();
      }
    });
  }

  Future<bool> _confirmBeforeQuitting() async {
    var willLeave = false;
    await showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('End Match'),
        content: const Text('Are you sure you want to quit?'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.pop(context);
              willLeave = true;
            },
          ),
          OutlinedButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(context);
              willLeave = false;
            },
          ),
        ],
      );
    });
    return willLeave;
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
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
    return WillPopScope(
      onWillPop: _confirmBeforeQuitting,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black.withOpacity(0.1),
          elevation: 0,
          title: const Text('')
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              SlidingUpPanel(

                controller: panelController,

                onPanelOpened: () {
                 _disableStreetViewGestures();
                },

                onPanelClosed: () {
                  _enableStreetViewGestures();
                },

                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),

                minHeight: 0,
                isDraggable: false,
                panel: _locationFound ? CountrySelect(
                  actualPosition: Coordinates(
                    _coordinates.latitude, _coordinates.longitude
                  ),
                  unit: _unit,
                ) : const Text(''),
                body: FlutterGoogleStreetView(

                  initPos: LatLng(_coordinates.latitude, _coordinates.longitude),
                  initRadius: _searchRadius,

                  initSource: StreetViewSource.def,
                  streetNamesEnabled: false,

                  onStreetViewCreated: (StreetViewController controller) async {
                    streetViewController = controller;
                  },

                  onPanoramaChangeListener: (location, e) {
                    if (!_locationFound) {
                      if (location == null) {
                        _generateValidCoordinates();
                      } else {
                        _foundLocation();
                        _setPanoId(location.panoId);
                      }
                    }
                  },
                ),
              ),
              Visibility(
                visible: !_locationFound,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Setting up the turf")
                    ],
                  )
                )
              )
            ],
          )
        ),

        floatingActionButton: Visibility(
          visible: _locationFound,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: !_panelIsOpen,
                child: FloatingActionButton(
                  heroTag: 'btnReset',
                  tooltip: "Back to start",
                  child: const FaIcon(FontAwesomeIcons.houseFlag),
                  onPressed: () {
                   _gotoInitialStreetView();
                  },
                ),
              ),

              const SizedBox(height: 10),

              FloatingActionButton(
                heroTag: 'btnToggleMap',
                tooltip: _panelIsOpen ? "Close" : "Open",
                child: FaIcon(
                  _panelIsOpen ? FontAwesomeIcons.xmark: FontAwesomeIcons.earthAmericas
                ),
                onPressed: () {
                  _togglePanel();
                },
              ),
            ],
          ),
        ),

      ),
    );
  }
}

