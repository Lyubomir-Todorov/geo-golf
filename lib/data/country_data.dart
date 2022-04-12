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

List<GeographicArea> areasToSearch = [
  GeographicArea("North America", const LatLng(36.385913, -100.011074), 2345406),
  GeographicArea("Eastern Canada", const LatLng(49.21042, -74.082199), 1244030),
  GeographicArea("Western Canada", const LatLng(-126.820767, 56.170023), 872226),
  GeographicArea("Goose Bay Labrador Canada", const LatLng(53.310365, -60.379335), 6822),
  GeographicArea("Halifax NS Canada", const LatLng(44.655222, -63.593293), 11954),
  GeographicArea("Greater Halifax Area NS Canada", const LatLng(44.787683, -63.151318), 17715),
  GeographicArea("Narsarsuaq Greenland", const LatLng(61.156488, -45.537594), 9373),
  GeographicArea("Reykjavik Iceland", const LatLng(64.139369, -21.914278), 62830),
  GeographicArea("Brittany France", const LatLng(47.753406, -3.3793), 6011),
  GeographicArea("Rennes France", const LatLng(48.110641, -1.678711), 9636),
  GeographicArea("Switzerland", const LatLng(46.950262, 7.449308), 46106),
  GeographicArea("Lichtenstein", const LatLng(47.152369, 9.548686), 26129),
  GeographicArea("Munich Germany", const LatLng(48.136767, 11.593054), 68918),
  GeographicArea("Frankfurt Germany", const LatLng(50.120578, 8.670553), 38971),
  GeographicArea("Hunedoara Romania", const LatLng(45.760338, 22.902518), 7167),
  GeographicArea("Bucharest Romania", const LatLng(44.441624, 26.104667), 46933),
  GeographicArea("Burgas Bulgaria", const LatLng(42.509059, 27.468038), 16502),
  GeographicArea("Istanbul Turkey", const LatLng(41.097982, 29.012904), 45678),
  GeographicArea("Sparta Greece", const LatLng(37.08038, 22.427952), 34911),
  GeographicArea("Naples Italy", const LatLng(37.08038, 22.427952), 34911),
  GeographicArea("Sicily", const LatLng(37.514083, 14.080226), 56977),
  GeographicArea("Madrid Spain", const LatLng(40.430224, -3.711208), 62664),
  GeographicArea("Dubai", const LatLng(25.115445, 55.473253), 97385),
  GeographicArea("Ghana", const LatLng(8.233237, -1.269438), 407914),
  GeographicArea("Durban South Africa", const LatLng(-29.797751, 30.749529), 35090),
  GeographicArea("Thailand", const LatLng(14.902322, 101.035176), 221143),
  GeographicArea("Taiwan", const LatLng(23.815501, 120.961987), 189805),
  GeographicArea("Seoul Korea", const LatLng(37.51844, 126.991869), 44118),
  GeographicArea("Kurume Japan", const LatLng(33.371825, 130.507227), 38355),
  GeographicArea("Kyoto Japan", const LatLng(35.01875, 135.742907), 26080),
  GeographicArea("Tokyo Japan", const LatLng(36.018004, 139.868172), 96719),
  GeographicArea("Singapore", const LatLng(1.345701, 103.824139), 22852),
  GeographicArea("Western Australia", const LatLng(-29.91685, 117.690587), 589457),
  GeographicArea("Eastern Australia", const LatLng(-33.541395, 148.152355), 581835),
  GeographicArea("N New Zealand", const LatLng(-38.513788, -184.038045), 361379),
  GeographicArea("S New Zealand", const LatLng(-44.197959, -189.995504), 312838),
  GeographicArea("Hawaii", const LatLng(19.642588, -155.57079), 91984),
  GeographicArea("Guam", const LatLng(13.460415, -215.223239), 27043),
  GeographicArea("Mexico City Mexico", const LatLng(19.68397, -99.267061), 234121),
  GeographicArea("Colombia", const LatLng(5.845545, -74.561737), 220075),
  GeographicArea("East Brazil", const LatLng(-7.122696, -38.403184), 450564),
  GeographicArea("Uruguay", const LatLng(-33.11915, -56.046242), 254644),
  GeographicArea("London England", const LatLng(51.529251, -0.139572), 36888),
  GeographicArea("Limerick Ireland", const LatLng(52.662225, -8.622053), 12602),
];