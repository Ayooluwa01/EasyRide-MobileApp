import 'package:flutter/foundation.dart' show immutable;

@immutable
class RideDestination {
  const RideDestination({
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });

  final String title;
  final String subtitle;
  final double lat;
  final double lng;
}

@immutable
class RouteInfo {
  const RouteInfo({
    required this.baseFare,
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final num baseFare;
  final List<List<double>> coordinates;
  final double distanceMeters;
  final double durationSeconds;

  String get distanceLabel =>
      '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  String get durationLabel {
    final minutes = (durationSeconds / 60).round();
    return '$minutes min';
  }

  String get fareLabel => '₦${baseFare.toStringAsFixed(0)}';
}
