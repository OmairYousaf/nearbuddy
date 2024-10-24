import 'dart:math';

class MapFunctions {
  static double? zoomOut(double radius, zoomLevel) {
    if (radius > 0) {
      double radiusElevated = radius + radius / 2;
      double scale = radiusElevated /
          5.5; //change this denominator according to radius (the greater the value of the denominator the lower it zooms out (scales out)
      zoomLevel = (14 -
          log(scale) / log(2)); //this formula is copied from stackoverflow
    }
    return num.parse(zoomLevel.toStringAsFixed(2)) as double?;
  }

  static double? zoomIn(double radius, zoomLevel) {
    if (radius > 0) {
      double radiusReduced = 5 - 5 / 2;
      double scale = radiusReduced /
          20.5; //change this denominator according to radius (the greater the value of the denominator the higher it zooms in (scales in)
      zoomLevel = (12 -
          log(scale) / log(2)); //this formula is copied from stackoverflow
    }
    return num.parse(zoomLevel.toStringAsFixed(2)) as double?;
  }
}
