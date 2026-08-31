class LocationSuggestionResponse {
  final bool success;
  final int statusCode;
  final List<LocationSuggestion> data;

  LocationSuggestionResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory LocationSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return LocationSuggestionResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => LocationSuggestion.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class LocationSuggestion {
  final String title;
  final String subtitle;
  final double lng;
  final double lat;

  LocationSuggestion({
    required this.title,
    required this.subtitle,
    required this.lng,
    required this.lat,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      lng: (json['lng'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );
  }
}

class GetRouteRequest {
  final double originLng;
  final double originLat;
  final double destLng;
  final double destLat;

  GetRouteRequest({
    required this.originLng,
    required this.originLat,
    required this.destLng,
    required this.destLat,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'originLng': originLng,
      'originLat': originLat,
      'destLng': destLng,
      'destLat': destLat,
    };
  }
}

class GetRouteResponse {
  final bool success;
  final int statusCode;
  final RouteData data;

  GetRouteResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory GetRouteResponse.fromJson(Map<String, dynamic> json) {
    return GetRouteResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: RouteData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class RouteData {
  final num baseFare;
  final List<List<double>> coordinates;
  final double distanceMeters;
  final double durationSeconds;

  RouteData({
    required this.baseFare,
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      baseFare: json['baseFare'] as num,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map(
            (coordinate) => (coordinate as List<dynamic>)
                .map((value) => (value as num).toDouble())
                .toList(),
          )
          .toList(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
    );
  }
}
