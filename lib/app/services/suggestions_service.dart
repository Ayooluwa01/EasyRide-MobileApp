import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/models/mapbox_location_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuggestionsService {
  final Ref ref;

  SuggestionsService(this.ref);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<LocationSuggestionResponse> getLocationSuggestion(
    String location,
    String sessionToken,
    String latitude,
    String longitude,
  ) async {
    final response = await _apiClient.post(
      Endpoints.getLocations,
      data: {
        'location': location,
        'sessionToken': sessionToken,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return LocationSuggestionResponse.fromJson(response.data);
  }

  Future<PlaceDetailsResponse> getPlaceDetails(String placeId) async {
    final response = await _apiClient.post(
      Endpoints.getPlaceDetails,
      data: {'placeId': placeId},
    );

    return PlaceDetailsResponse.fromJson(response.data);
  }

  Future<PlaceDetailsResponse> reverseGeocode(double lat, double lng) async {
    final response = await _apiClient.post(
      Endpoints.reverseGeocode,
      data: {'latitude': lat, 'longitude': lng},
    );

    return PlaceDetailsResponse.fromJson(response.data);
  }
}

final suggestionsServiceProvider = Provider<SuggestionsService>((ref) {
  return SuggestionsService(ref);
});
