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

    const _minLat = -80;
    const _maxLat = 84;
    const _minLon = -180;
    const _maxLon = 180;

    // Picks a random latitude and longitude within a given radius

    // Each geographic area has a center point, as defined by a lat and lon
    // Convert that lat and lon to UTM values, they are values in meters
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


    print("COORDINATES! ${result.lon} ${result.lat}");
    return LatLng(result.lat, result.lon);
  }
  
}

List<GeographicArea> areasToSearch = [
  GeographicArea("North America", const LatLng(36.385913, -100.011074), 2345406),
  GeographicArea("Eastern Canada", const LatLng(49.21042, -74.082199), 1244030),
  GeographicArea("Western Canada", const LatLng(-126.820767, 56.170023), 872226),
];

List<Country> countries = [
  Country("Afghanistan"),
  Country("Angola"),
  Country("Albania"),
  Country("United Arab Emirates"),
  Country("Argentina"),
  Country("Armenia"),
  Country("Australia"),
  Country("Austria"),
  Country("Azerbaijan"),
  Country("Burundi"),
  Country("Belgium"),
  Country("Benin"),
  Country("Burkina Faso"),
  Country("Bangladesh"),
  Country("Bulgaria"),
  Country("Bahamas"),
  Country("Bosnia and Herz."),
  Country("Belarus"),
  Country("Belize"),
  Country("Bolivia"),
  Country("Brazil"),
  Country("Brunei"),
  Country("Bhutan"),
  Country("Botswana"),
  Country("Central African Rep."),
  Country("Canada"),
  Country("Switzerland"),
  Country("Chile"),
  Country("China"),
  Country("CÃ´te d'Ivoire"),
  Country("Cameroon"),
  Country("Dem. Rep. Congo"),
  Country("Congo"),
  Country("Colombia"),
  Country("Costa Rica"),
  Country("Cuba"),
  Country("N. Cyprus"),
  Country("Cyprus"),
  Country("Czech Rep."),
  Country("Germany"),
  Country("Djibouti"),
  Country("Denmark"),
  Country("Dominican Rep."),
  Country("Algeria"),
  Country("Ecuador"),
  Country("Egypt"),
  Country("Eritrea"),
  Country("Spain"),
  Country("Estonia"),
  Country("Ethiopia"),
  Country("Finland"),
  Country("Fiji"),
  Country("Falkland Is."),
  Country("France"),
  Country("Gabon"),
  Country("United Kingdom"),
  Country("Georgia"),
  Country("Ghana"),
  Country("Guinea"),
  Country("Gambia"),
  Country("Guinea-Bissau"),
  Country("Eq. Guinea"),
  Country("Greece"),
  Country("Greenland"),
  Country("Guatemala"),
  Country("Guyana"),
  Country("Honduras"),
  Country("Croatia"),
  Country("Haiti"),
  Country("Hungary"),
  Country("Indonesia"),
  Country("India"),
  Country("Ireland"),
  Country("Iran"),
  Country("Iraq"),
  Country("Iceland"),
  Country("Israel"),
  Country("Italy"),
  Country("Jamaica"),
  Country("Jordan"),
  Country("Japan"),
  Country("Kazakhstan"),
  Country("Kenya"),
  Country("Kyrgyzstan"),
  Country("Cambodia"),
  Country("Korea"),
  Country("Kosovo"),
  Country("Kuwait"),
  Country("Lao PDR"),
  Country("Lebanon"),
  Country("Liberia"),
  Country("Libya"),
  Country("Sri Lanka"),
  Country("Lesotho"),
  Country("Lithuania"),
  Country("Luxembourg"),
  Country("Latvia"),
  Country("Morocco"),
  Country("Moldova"),
  Country("Madagascar"),
  Country("Mexico"),
  Country("Macedonia"),
  Country("Mali"),
  Country("Myanmar"),
  Country("Montenegro"),
  Country("Mongolia"),
  Country("Mozambique"),
  Country("Mauritania"),
  Country("Malawi"),
  Country("Malaysia"),
  Country("Namibia"),
  Country("New Caledonia"),
  Country("Niger"),
  Country("Nigeria"),
  Country("Nicaragua"),
  Country("Netherlands"),
  Country("Norway"),
  Country("Nepal"),
  Country("New Zealand"),
  Country("Oman"),
  Country("Pakistan"),
  Country("Panama"),
  Country("Peru"),
  Country("Philippines"),
  Country("Papua New Guinea"),
  Country("Poland"),
  Country("Puerto Rico"),
  Country("Dem. Rep. Korea"),
  Country("Portugal"),
  Country("Paraguay"),
  Country("Palestine"),
  Country("Qatar"),
  Country("Romania"),
  Country("Russia"),
  Country("Rwanda"),
  Country("W. Sahara"),
  Country("Saudi Arabia"),
  Country("Sudan"),
  Country("S. Sudan"),
  Country("Senegal"),
  Country("Solomon Is."),
  Country("Sierra Leone"),
  Country("El Salvador"),
  Country("Somaliland"),
  Country("Somalia"),
  Country("Serbia"),
  Country("Suriname"),
  Country("Slovakia"),
  Country("Slovenia"),
  Country("Sweden"),
  Country("Swaziland"),
  Country("Syria"),
  Country("Chad"),
  Country("Togo"),
  Country("Thailand"),
  Country("Tajikistan"),
  Country("Turkmenistan"),
  Country("Timor-Leste"),
  Country("Trinidad and Tobago"),
  Country("Tunisia"),
  Country("Turkey"),
  Country("Taiwan"),
  Country("Tanzania"),
  Country("Uganda"),
  Country("Ukraine"),
  Country("Uruguay"),
  Country("United States of America"),
  Country("Uzbekistan"),
  Country("Venezuela"),
  Country("Vietnam"),
  Country("Vanuatu"),
  Country("Yemen"),
  Country("South Africa"),
  Country("Zambia"),
  Country("Zimbabwe"),
];
