import 'package:final_project/classes/results.dart';
import 'package:final_project/enum/distance.dart';
import 'package:final_project/screens/street_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:georange/georange.dart';
import 'package:nanoid/nanoid.dart';

import '../classes/guess.dart';

import 'stats.dart' as stats;


GeoRange georange = GeoRange();

class CountrySelect extends StatefulWidget {
  final Coordinates actualPosition;
  final Distance unit;
  const CountrySelect({Key? key, required this.actualPosition, required this.unit}) : super(key: key);

  @override
  _CountrySelectState createState() => _CountrySelectState();
}

class _CountrySelectState extends State<CountrySelect> {

  // Google maps examples can be found here!
  // https://github.com/flutter/plugins/tree/main/packages/google_maps_flutter/google_maps_flutter/example/lib

  int _markerIdCounter = 1;
  int _guessesRemaining = 5;

  GoogleMapController? _controller;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  LatLng? _guessPosition;
  Coordinates? _actualPosition;

  final List<Guess> _guesses = [];
  double? _bestDistance;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    Wakelock.enable();
    super.initState();
    _actualPosition = widget.actualPosition;
  }

  void _onMapTap(LatLng coords) => _setGuessLocation(coords);

  void _setGuessLocation(LatLng coords) {

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      consumeTapEvents: true,
      markerId: markerId,
      position: coords
    );

    setState(() {
      _markers[markerId] = marker;
      _guessPosition = coords;
    });

  }

  void _calculateDistance() {

    var distance = georange.distance(
      Point(latitude: _guessPosition!.latitude, longitude: _guessPosition!.longitude),
      Point(latitude: _actualPosition!.latitude, longitude: _actualPosition!.longitude)
    );

    GuessRank quality;
    quality = GuessQuality.getRank(distance);

    setState(() {

      _guesses.add(Guess(coordinates: _guessPosition!, distance: distance, quality: quality));

      final String markerIdVal = 'marker_id_$_markerIdCounter';
      final MarkerId markerId = MarkerId(markerIdVal);

      final Marker? marker = _markers[markerId]?.copyWith(
        iconParam: _guesses[_markerIdCounter-1].getMarkerColor(),
      );

      _markers[markerId] = marker!;
      _markerIdCounter++;
      _guessPosition = null;

      _bestDistance = _guesses.reduce(
        (value, element) => value.distance < element.distance ? value : element
      ).distance;

      _guessesRemaining --;
    });

    _endOfMatch();

  }

  _endOfMatch() {
    if (_guessesRemaining == 0) {
      _createActualPositionMarker();
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      Navigator.pushNamed(
        context, '/match_results',
        arguments: stats.ScreenArguments(Results(_guesses, _markers), nanoid(), false, widget.unit)
      );
    }
  }

  // https://github.com/flutter/plugins/blob/c5f34ad891cc4d47c821bf1309da734e69a98f96/packages/google_maps_flutter/google_maps_flutter/example/lib/marker_icons.dart#L75

  _createActualPositionMarker() {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    final MarkerId markerId = MarkerId(markerIdVal);
    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      consumeTapEvents: true,
      markerId: markerId,
      position: LatLng(_actualPosition!.latitude, _actualPosition!.longitude)
    );
    _guesses.add(Guess(coordinates: LatLng(_actualPosition!.latitude, _actualPosition!.longitude), distance: 0, quality: GuessRank.excellent));
    _markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 8.0
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.locationDot),
                      const SizedBox(width: 8.0),
                      Text(_guessesRemaining.toString()),
                      const SizedBox(width: 4.0),
                    ],
                  ),
                ),
              ),
              _guesses.isNotEmpty ? Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 8.0
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Best distance: ${widget.unit == Distance.metric ? DistanceConversion.getDistanceAsMetric(_bestDistance!, 0) : DistanceConversion.getDistanceAsImperial(_bestDistance!, 0)}'
                  ),
                ),
              ): const Text('')
            ],
          ),

          Visibility(
            visible: _guessPosition!=null,
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {_calculateDistance();},
                  child: const Text('Guess!')
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}