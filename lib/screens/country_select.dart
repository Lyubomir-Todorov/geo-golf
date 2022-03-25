import 'package:final_project/screens/street_view.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:georange/georange.dart';

// TODO -> Save camera position and marker location as arguments

GeoRange georange = GeoRange();

class CountrySelect extends StatefulWidget {
  const CountrySelect({Key? key}) : super(key: key);

  @override
  _CountrySelectState createState() => _CountrySelectState();
}

class _CountrySelectState extends State<CountrySelect> {

  // Google maps examples can be found here!
  // https://github.com/flutter/plugins/tree/main/packages/google_maps_flutter/google_maps_flutter/example/lib
  final int _markerIdCounter = 1;

  GoogleMapController? controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  LatLng? markerPosition;

  Marker? guessMarker;
  LatLng? _guessPosition;

  Coordinates? _actualPosition;


  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
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
  }

  void _onMapTap(LatLng coords) {
    print("This is getting triggered every time we tap the map... hopefully :)");
    print("Tapped at ${coords.latitude} ${coords.longitude}");

    _setGuessLocation(coords);
  }

  void _setGuessLocation(LatLng coords) {

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      consumeTapEvents: true,
      markerId: markerId,
      position: coords
    );

    setState(() {
      markers[markerId] = marker;
      _guessPosition = coords;
    });

    _calculateDistance();
  }

  void _calculateDistance() {
    Point point1 = Point(latitude: _guessPosition!.latitude, longitude: _guessPosition!.longitude); //Mombasa
    Point point2 = Point(latitude: _actualPosition!.latitude, longitude: _actualPosition!.longitude); // Nairobi

    var distance = georange.distance(point1, point2);
    print(distance);
  }

  @override
  Widget build(BuildContext context) {
    _actualPosition = ModalRoute.of(context)!.settings.arguments as Coordinates;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                onTap: _onMapTap,
                zoomControlsEnabled: false,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(30, -45),
                ),
                markers: Set<Marker>.of(markers.values),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _guessPosition == null ? null : () {},
                child: const Text('GUESS!'),
              ),
            )
          ],
        ),
      ),
    );
  }
}