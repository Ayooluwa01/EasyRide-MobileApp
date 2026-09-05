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
  final String placeId;

  LocationSuggestion({
    required this.title,
    required this.subtitle,
    required this.placeId,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      placeId: json['placeId'] as String,
    );
  }
}

class PlaceDetailsResponse {
  final bool success;
  final int statusCode;
  final PlaceDetails data;

  PlaceDetailsResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory PlaceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PlaceDetailsResponse(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      data: PlaceDetails.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String address;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      placeId: json['placeId'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
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

  Map<String, dynamic> toJson() {
    return {
      'origin': {'latitude': originLat, 'longitude': originLng},
      'destination': {'latitude': destLat, 'longitude': destLng},
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
  final String polyline;
  final double distanceMeters;
  final double durationSeconds;

  RouteData({
    required this.baseFare,
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      baseFare: json['baseFare'] as num,
      polyline: json['polyline'] as String,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
    );
  }
}
