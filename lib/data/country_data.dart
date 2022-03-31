import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:utm/utm.dart';

import 'dart:math' as math;

class Country {
  late String name;

  Country(this.name);
}

math.Random ran = math.Random();

class GeographicArea {

  late String name;
  late LatLng coords;
  late double radius;

  GeographicArea(this.name, this.coords, this.radius);

  LatLng getRandomPointWithinRadius() {
    // Picks a random latitude and longitude within a given radius

    // Each geographic area has a center point, as defined by a lat and lon
    // Convert that lat and lon to UTM values, represented in meters
    // Get that random value within the circle as a UTM value as well
    // Combine both together, and convert back to a usable geodetic set (lat,lon)

    final coordinatesAsUTM = UTM.fromLatLon(lat: coords.latitude, lon: coords.longitude);

    var r = radius * math.sqrt(ran.nextDouble());
    var theta = ran.nextDouble() * 2 * math.pi;

    var x = (coordinatesAsUTM.easting + r * math.cos(theta)).abs();
    var y = (coordinatesAsUTM.northing + r * math.sin(theta)).abs();

    final result = UTM.fromUtm(
      easting: x,
      northing: y,
      zoneNumber: coordinatesAsUTM.zoneNumber,
      zoneLetter: coordinatesAsUTM.zoneLetter
    );

    return LatLng(result.lat, result.lon);
  }
}

// TODO -> Add more locations!
// Easiest way is through https://geoman.io/geojson-editor
// Start with locations of interest, i.e. major cities, landmarks, what not
// Avoid water !!!!
// heads up if you use this website however, flip the coordinates around. Their longitude is the first value for some reason
// We want it formatted as Latitude, Longitude

List<GeographicArea> areasToSearch = [
  GeographicArea("North America", const LatLng(36.385913, -100.011074), 2345406),
  GeographicArea("Eastern Canada", const LatLng(49.21042, -74.082199), 1244030),
  GeographicArea("Western Canada", const LatLng(-126.820767, 56.170023), 872226),
];