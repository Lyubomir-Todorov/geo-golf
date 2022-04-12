enum Distance { metric, imperial }

abstract class DistanceConversion {

  static const double kmToMi = 0.621371;

  static String getDistanceAsMetric(double distance, int precision) =>
      (distance < 1) ?
      "${(distance*1000).toStringAsFixed(precision)} m" :
      "${distance.toStringAsFixed(precision)} km";

  static String getDistanceAsImperial(double distance, int precision) {
    distance *= kmToMi;
    return (distance) < 1 ?
      "${(distance*1760).toStringAsFixed(precision)} yards" :
      "${distance.toStringAsFixed(precision)} mi";
  }

}