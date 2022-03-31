import 'package:final_project/classes/match_history.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:async/async.dart';

import '../classes/guess.dart';
import '../classes/results.dart';

// TODO -> For the chart requirement, show past 30 days and closest distance?
// TODO -> Match history, favourite certain matches

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin<Stats> {

  List<MatchHistory> match = [];
  List<MatchHistory> matchFavourite = [];


  List<Guess> _guesses = [];
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 1;
  bool _showAll = true;

  Map<String, dynamic> _data = {};
  DocumentReference matches =  FirebaseFirestore.instance.collection('match_history')
      .doc(FirebaseAuth.instance.currentUser?.uid);

  late Future<DocumentSnapshot> future;

  Future<DocumentSnapshot> _getMatchHistory() async {
    return matches.get();
  }

  _setMatchSpecificData(int index) {

    _guesses.clear();
    _markers.clear();
    _markerIdCounter = 1;

    // Get only the data pertaining to the specific match clicked
    Map<String, dynamic> _dataIndex = _data['data'][index];
    List _dataGuesses = _dataIndex['guesses'];

    // Iterate through 5 guesses and convert them to actual map markers
    for(var i in _dataGuesses) {
      LatLng coord = LatLng(i['lat'], i['lon']);
      Guess guess = Guess(coord, i['distance'], GuessRank.values[i['quality']]);

      _guesses.add(guess);

      final String markerIdVal = 'marker_id_${_markerIdCounter++}';
      final MarkerId markerId = MarkerId(markerIdVal);
      Marker marker = Marker(
        icon: guess.getMarkerColor(),
        consumeTapEvents: true,
        markerId: markerId,
        position: LatLng(coord.latitude, coord.longitude)
      );
      _markers[markerId] = marker;
    }

    // Add the marker that corresponds to actual location

    LatLng coord = LatLng(_dataIndex['actual_location']['lat'], _dataIndex['actual_location']['lon']);
    Guess guess = Guess(coord, 0, GuessRank.excellent);

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
    _setMatchSpecificData(index);
    Navigator.pushNamed(context, '/match_results',
      arguments: Results(_guesses, _markers, isHistorical: true)
    );
  }

  _toggleShow() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  _toggleFavourite(int index) {

    // TODO -> Fix this mess lol

    setState(() {
      match[index].favourite = !match[index].favourite;
      if (!_showAll) {
        matchFavourite.removeAt(index);
      }
    });

    try {
      DocumentReference matches = FirebaseFirestore.instance.collection('match_history').doc(FirebaseAuth.instance.currentUser?.uid);

      matches.update({
        "${match[index].uid}.favourite" : match[index].favourite,
      }).then((value) => print("Match history Added"))
        .catchError((error) => print("Failed to add match history: $error"));

    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }


  }

  List<Color> gradientColors = [
    const Color(0xff13ff84),
    const Color(0xff13ff84),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    future = _getMatchHistory();
    super.initState();
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
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                    child: Text("Something went wrong, please try again!")
                );
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Center(
                  child: Text("No matches were found")
                );
              }

              // TODO -> Fix Favouring
              // When we favourite one of the list items, we use setState() to rerender the item and show updates
              // The problem is, futurebuilder is also rebuilt each time
              // This is why we can't see anything changing
              // Our future has been called already so we wont get the new values from firebase
              // And we remake the lists using that old future...

              if (snapshot.connectionState == ConnectionState.done) {
                match = [];
                matchFavourite = [];

                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                _data = data;

                data.forEach((uid, map) {
                  var m = map;
                  var g = m['guesses'] as List;
                  List<LatLng> coords = [];

                  for (var element in g) {
                    coords.add(LatLng(element['lat'], element['lon']));
                  }

                  var mat = MatchHistory(
                    m['date'],
                    m['time'],
                    coords,
                    m['favourite'],
                    m['best_distance'],
                    m['uid']
                  );

                  match.add(mat);
                  if (mat.favourite) matchFavourite.add(mat);

                });

                // Chart documentation here
                // https://github.com/imaNNeoFighT/fl_chart/blob/master/repo_files/documentations/line_chart.md#sample-1-source-code

                return Column(
                  children: [
                    Flexible(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                        // TODO -> Move chart to a separate file
                        child: LineChart(
                          LineChartData(
                            backgroundColor: Color(0xff3b315e),
                            borderData: FlBorderData(
                              show: false
                            ),
                            // TODO -> Change to show y-axis only
                            titlesData: FlTitlesData(
                              show: false
                            ),
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: const Color(0xff42395b),
                                  strokeWidth: 3,
                                );
                              },
                            ),
                            minY: 0,
                            maxY: 10,
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 5),
                                  FlSpot(1, 5),
                                  FlSpot(2, 5),
                                  FlSpot(3, 7),
                                  FlSpot(4, 5),
                                  FlSpot(5, 5),
                                ],
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                barWidth: 8,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorTween(begin: gradientColors[0], end: gradientColors[1])
                                          .lerp(0.2)!
                                          .withOpacity(0.4),
                                      ColorTween(begin: gradientColors[0], end: gradientColors[1])
                                          .lerp(0.2)!
                                          .withOpacity(0.4),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

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
                      child: ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: match.length,
                        itemBuilder: (context, index) {

                          return Card(
                            elevation: 3.0,
                            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4.0),
                            child: ListTile(
                              title: Text('${match[index].bestDistance} km'),
                              subtitle: Text('${match[index].date} - ${match[index].time}'),
                              leading: IconButton(
                                onPressed: () {_navigateToMatchResults(index);},
                                icon: const FaIcon(FontAwesomeIcons.locationPin),
                                tooltip: "View on map",
                              ),
                              trailing: IconButton(
                                // TODO -> Make this actually favourite it
                                onPressed: () {
                                  _toggleFavourite(index);
                                },
                                // TODO -> Reflect changes in icon
                                icon: FaIcon(
                                  match[index].favourite ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star
                                ),
                                tooltip: match[index].favourite ? "Remove from favourites" : "Add to favourites",
                                color: Colors.orange,
                                iconSize: 20,
                              ),
                            ),
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