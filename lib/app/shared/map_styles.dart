// app/shared/theme/map_styles.dart

import 'package:flutter/material.dart';

class MapStyles {
  // Prevent instantiation
  MapStyles._();

  // Unified Single Google Cloud Map ID
  static const String mapId = "YOUR_SINGLE_MAP_ID_HERE";

  // Clean Light Mode Layout (Hides noisy local streets, POIs, and transit points)
  static const String light = '''
  [
    { "featureType": "poi", "elementType": "all", "stylers": [{ "visibility": "off" }] },
    { "featureType": "transit", "elementType": "all", "stylers": [{ "visibility": "off" }] },
    { "featureType": "road.local", "elementType": "labels", "stylers": [{ "visibility": "off" }] }
  ]
  ''';

  // High-Contrast Clean Dark Mode Layout
  static const String dark = '''
  [
    { "elementType": "geometry", "stylers": [{ "color": "#121212" }] },
    { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
    { "featureType": "transit", "stylers": [{ "visibility": "off" }] },
    { "featureType": "road.local", "elementType": "labels", "stylers": [{ "visibility": "off" }] },
    { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": "#1f1f1f" }] },
    { "featureType": "road", "elementType": "geometry.stroke", "stylers": [{ "color": "#2c2c2c" }] },
    { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#000000" }] }
  ]
  ''';

  static String getStyleForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
