import 'package:final_project/classes/match_history.dart';
import 'package:final_project/enum/distance.dart';
import 'package:final_project/widgets/chart_per_match.dart';
import 'package:final_project/widgets/chart_performance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../classes/guess.dart';
import '../classes/results.dart';
import '../classes/toast.dart';

class ScreenArguments {
  late Results results;
  late String uid;
  late bool favourite;
  late Distance unit;

  ScreenArguments(this.results, this.uid, this.favourite, this.unit);
}

class Stats extends StatefulWidget {
  setFuture() => createState()._setMatchHistory();
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin<Stats> {

  List<MatchHistory> match = [];
  List<MatchHistory> matchFavourite = [];

  final List<Guess> _guesses = [];
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 1;
  bool _showAll = true;
  Distance _unit = Distance.metric;

  final CarouselController _carouselController = CarouselController();
  int _carouselIndex = 0;

  late Future<DocumentSnapshot> future;

  Future<DocumentSnapshot> _getMatchHistory() async {

    DocumentReference matches =  FirebaseFirestore.instance.collection('match_history')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    return await matches.get();
  }

  _getUnitPreference() {
    DocumentReference user =  FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    user.get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      _unit = Distance.values[data['unit']];
    });
  }



  _setMatchHistory() {
    setState(() {
      match.clear();
      matchFavourite.clear();
      future = _getMatchHistory();
      _setMatchData(future);
    });
  }

  _setMatchData(Future<DocumentSnapshot> d) {

    // Sort each match by timestamp
    // Since each field in match_history has a uniquely generated id
    // They are NOT in order when we retrieve them from Firebase

    d.then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      data.forEach((key, value) {
        var mat = MatchHistory.fromJson(value);
        match.add(mat);
      });
      match.sort((a, b) {
        var aAsDate = DateTime.parse(a.timestamp);
        var bAsDate = DateTime.parse(b.timestamp);
        return bAsDate.compareTo(aAsDate);
      });
      matchFavourite = match.where((element) => element.favourite).toList();
    });

  }

  _setMatchSpecificData(int index) {

    _guesses.clear();
    _markers.clear();
    _markerIdCounter = 1;

    // Get only the data pertaining to the specific match clicked

    int ind = index;
    if (!_showAll) ind = match.indexOf(matchFavourite[index]);

    MatchHistory mat = match[ind];

    // Iterate through 5 guesses and convert them to actual map markers
    for(var i in mat.coords) {

      _guesses.add(i);

      final String markerIdVal = 'marker_id_${_markerIdCounter++}';
      final MarkerId markerId = MarkerId(markerIdVal);
      Marker marker = Marker(
        icon: i.getMarkerColor(),
        consumeTapEvents: true,
        markerId: markerId,
        position: i.coordinates
      );
      _markers[markerId] = marker;
    }

    // Add the marker that corresponds to actual location

    LatLng coord = mat.actual;
    Guess guess = Guess(coordinates: coord, distance: 0, quality: GuessRank.excellent);

    _guesses.add(guess);

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    final MarkerId markerId = MarkerId(markerIdVal);
    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      consumeTapEvents: true,
      markerId: markerId,
      position: LatLng(coord.latitude, coord.longitude)
    );
    _markers[markerId] = marker;

  }

  _navigateToMatchResults(int index) {

    int ind = index;
    if (!_showAll) ind = match.indexOf(matchFavourite[index]);

    _setMatchSpecificData(index);

    Navigator.pushNamed(context, '/match_results',
      arguments: ScreenArguments(
        Results(_guesses, _markers, isHistorical: true), match[ind].uid, match[ind].favourite, _unit
      )
    ).whenComplete(() {
      _setMatchHistory();
    });
  }

  _toggleShow() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  _toggleFavourite(int index) {

    // Indices between match and matchFavourite are not the same
    // If we are showing favourites, refer to match index based on the favourite object

    int ind = index;
    if (!_showAll) ind = match.indexOf(matchFavourite[index]);

    setState(() {
      match[ind].favourite = !match[ind].favourite;

      // Rebuild matchFavourite list, keeps chronological order that way
      matchFavourite = match.where((element) => element.favourite).toList();
    });

    try {
      DocumentReference matches = FirebaseFirestore.instance.collection('match_history').doc(FirebaseAuth.instance.currentUser?.uid);

      matches.update({
        "${match[ind].uid}.favourite" : match[ind].favourite,
      }).catchError((error) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error updating favourites!"));

    } on FirebaseAuthException catch (e) {
      Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, e.toString());
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {

    // Calls the future once in the component lifecycle
    // Otherwise, future is executed each time in the build cycle
    // This includes when we favourite and unfavourite things
    // Bad UX / Efficiency if we need to fetch from firebase each time we do that

    super.initState();
    future = _getMatchHistory();
    _getUnitPreference();
    _setMatchData(future);
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your stats'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString())
                );
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Center(
                  child: Text("No matches were found")
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {

                List<Widget> graphs = [
                  ChartPerformance(
                    unit: _unit,
                    data: _showAll ? match.reversed.toList():
                    matchFavourite.reversed.toList()
                  ),
                  ChartPerMatch(
                    unit: _unit,
                    data: _showAll ? match.reversed.toList():
                    matchFavourite.reversed.toList()
                  )
                ];

                return Column(
                  children: [
                    Flexible(
                      child: CarouselSlider(
                        carouselController: _carouselController,
                        items: graphs,
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _carouselIndex = index;
                            });
                          }
                        ),
                      )
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: graphs.asMap().entries.map((entry) {
                        double size = _carouselIndex == entry.key ? 8.0 : 7.0;
                        return GestureDetector(
                          onTap: () => _carouselController.animateToPage(entry.key),
                          child: Container(
                            width: size,
                            height: size,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black
                                .withOpacity(_carouselIndex == entry.key ? 0.7 : 0.4)),
                          ),
                        );
                      }).toList()
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _showAll ? null : () {_toggleShow();}, child: const Text("Show all")
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: !_showAll ? null : () {_toggleShow();}, child: const Text("Show favourites")
                        )
                      ],
                    ),
                    Flexible(
                      child: (!_showAll && matchFavourite.isEmpty) ?
                      const Center(child: Text('No favourite matches')) :
                      ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        itemCount: _showAll ? match.length : matchFavourite.length,
                        itemBuilder: (context, index) {
                          var m = _showAll ? match : matchFavourite;
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  _unit == Distance.imperial ?
                                  DistanceConversion.getDistanceAsImperial(m[index].bestDistance, 0):
                                  DistanceConversion.getDistanceAsMetric(m[index].bestDistance, 0)
                                ),
                                subtitle: Text('${m[index].date} - ${m[index].time}'),
                                leading: IconButton(
                                  onPressed: () {_navigateToMatchResults(index);},
                                  icon: const FaIcon(FontAwesomeIcons.locationPin),
                                  tooltip: "View on map",
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    _toggleFavourite(index);
                                  },
                                  icon: FaIcon(
                                    m[index].favourite ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star
                                  ),
                                  tooltip: m[index].favourite ? "Remove from favourites" : "Add to favourites",
                                  color: Colors.orange,
                                  iconSize: 20,
                                ),
                              ),
                              const Divider(thickness: 1),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
          ),
        ),
      ),
    );
  }
}